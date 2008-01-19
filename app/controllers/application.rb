# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
require "base64"
require "digest/sha1"
require_dependency "openid_login_system"

class ApplicationController < ActionController::Base
  include OpenidLoginSystem
  include ApplicationHelper
  include ActionView::Helpers::JavaScriptHelper
  include ActionView::Helpers::AssetTagHelper

  # Pick a unique cookie name to distinguish our session data from others'
  session :session_key => '_chatlino_session_id'

  before_filter :check_lang
  before_filter :check_me
  before_filter :add_stylesheets
  before_filter :add_javascripts
  after_filter :write_me

  def initialize
    @stylesheets = []
    @javascripts = []
  end

  protected
    def check_lang
      if !cookies[:lang]
        cookies[:lang] = 'zh_TW'
      end

      logger.info "Current lang = #{cookies[:lang]}"

      if params[:lang]
        @lang = cookies[:lang] = params[:lang]
      else
        @lang = cookies[:lang]
      end
    end

    def check_me
      if session[:user_id]
        begin
          @me = User.find(session[:user_id])
          return
        rescue Exception
          session[:user_id]=nil
        end
      end
      @me = User.new
      logger.info "user cookie = #{cookies[:user]}"
      if uc = cookies[:user]
        logger.info "has cookie"

        # validates the cookie data
        data = Base64.decode64(uc).split("-")
        if data.size == 4
          (sig, tstamp, uid, sonly) = data
          @session_only = ((sonly == "true") ? true : false)


          logger.info "has data"

          oursig = Digest::SHA1.hexdigest(USER_COOKIE_SECRET + tstamp + uid + sonly)

          if sig == oursig

            logger.info "has sig"

            stamptime = Time.at(tstamp.to_i)

            if Time.now < stamptime + USER_COOKIE_EXPIRATION
              logger.info "not expired"

              @me = User.find(uid.to_i)
              cookies[:last_email] = @me.email
            end
          end
        end

        # if still guest, which means the cookie is dirty
        if @me.is_guest?
          cookies.delete(:user)
        end
      end
    end

    def write_me
      return if @me.is_guest?

      uid = @me.id.to_s
      tstamp = Time.now.to_i.to_s
      sig = Digest::SHA1.hexdigest(USER_COOKIE_SECRET + tstamp + uid + @session_only.to_s)

      cstr = [sig, tstamp, uid, @session_only.to_s].join("-")
      cstr64 = Base64.encode64(cstr).gsub(/\n/, "")

      logger.info "writing, session only = #{@session_only}"

      cookies[:user] = {:value=>cstr64 , :expires=>USER_COOKIE_EXPIRATION.from_now}
    end

    def require_login
      if @me.is_guest?
        session[:redirect_to_after_login] = request.request_uri
        session[:return_to] = request.request_uri
        redirect_to :controller=>'openid_account', :action=>'login'
      end
    end


  def add_stylesheets
    ["#{controller_name}/_controller", "#{controller_name}/#{action_name}"].each do |stylesheet|
      @stylesheets << stylesheet if File.exists? "#{Dir.pwd}/public/stylesheets/#{stylesheet}.css"
    end
  end

  def add_javascripts
    script = "#{Dir.pwd}/public/javascripts/#{controller_name}.js"
    @javascripts << "#{controller_name}.js" if File.exists? script
  end

  def check_push_solution
    @push_solution = PUSH_SOLUTION
  end

end
