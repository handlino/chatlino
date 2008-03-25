require "pathname"
require "cgi"

# load the openid library

gem "ruby-openid", ">= 2.0.2"

require "openid"
require 'openid/store/filesystem'
require "openid/consumer"

class OpenidAccountController < ApplicationController
  def index
  end

  # process the login request, disover the openid server, and
  # then redirect.
  def login
    if openid_url = params[:openid_url]
      chkid = consumer.begin(openid_url)
      
      return_to = url_for(:action=> 'complete')
      realm = url_for :action => 'index', :only_path => false

      url = chkid.redirect_url(realm, return_to)

      redirect_to(url)
    end
  end

  # handle the openid server response
  def complete
    current_url = url_for(:action => 'complete', :only_path => false)
    parameters = params.reject{|k,v|request.path_parameters[k]}
    response = consumer.complete(parameters, current_url)

    case response.status
    when OpenID::Consumer::SUCCESS

      @user = User.find_by_openid_url(response.identity_url)

      # create user object if one does not exist
      if @user.nil?
        @user = User.new(:openid_url => response.identity_url)
        @user.nickname = response.identity_url
        if @user.save
          logger.debug("saved #{@user.id}")
        end
      end

      # storing both the openid_url and user id in the session for for quick
      # access to both bits of information.  Change as needed.
      session[:user_id] = @user.id

      flash[:notice] = "Logged in as #{CGI::escape(@user.shortname)}"

      redirect_back_or_default :controller => "chatroom", :action => "index"
      return

    when OpenID::Consumer::FAILURE
      if response.identity_url
        flash[:notice] = "Verification of #{response.identity_url} failed."

      else
        flash[:notice] = 'Verification failed.'
      end

    when OpenID::Consumer::CANCEL
      flash[:notice] = 'Verification cancelled.'

    else
      flash[:notice] = 'Unknown response from OpenID server.'
    end

    redirect_to :action => 'login'
  end

  def logout
    session[:user_id] = nil
  end

  def welcome
  end

  private

  # Get the OpenID::Consumer object.
  def consumer
    # Create the OpenID store for storing associations and nonces,
    # putting it in your app's db directory.
    # Note: see the plugin located at examples/active_record_openid_store
    # if you need to store this information in your database.
    store_dir = Pathname.new(RAILS_ROOT).join('tmp').join('openid-store')
    store = OpenID::Store::Filesystem.new(store_dir)

    return OpenID::Consumer.new(session, store)
  end

  # get the logged in user object
  def find_user
    return nil if session[:user_id].nil?
    User.find(session[:user_id])
  end

end
