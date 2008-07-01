class ApplicationController < ActionController::Base

  helper :all
  include AuthenticatedSystem

  before_filter :check_lang
  before_filter :add_stylesheets
  before_filter :add_javascripts

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

  def add_stylesheets
    ["#{controller_name}/_controller", "#{controller_name}/#{action_name}"].each do |stylesheet|
      @stylesheets << stylesheet if File.exists? "#{Dir.pwd}/public/stylesheets/#{stylesheet}.css"
    end
  end

  def add_javascripts
    script = "#{Dir.pwd}/public/javascripts/#{controller_name}.js"
    @javascripts << "#{controller_name}.js" if File.exists? script
  end

end
