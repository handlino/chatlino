# Be sure to restart your web server when you modify this file.

# Uncomment below to force Rails into production mode when
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.1.0' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here

  # Skip frameworks you're not going to use (only works if using vendor/rails)
  # config.frameworks -= [ :action_web_service, :action_mailer ]

  # Only load the plugins named here, by default all plugins in vendor/plugins are loaded
  # config.plugins = %W( exception_notification ssl_requirement )

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Force all environments to use the same logger level
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug

  # Use the database for sessions instead of the file system
  # (create the session table with 'rake db:sessions:create')
  # config.action_controller.session_store = :active_record_store
  config.action_controller.session = { 
    :session_key => "_chatlino_session", 
    :secret => "asd98u23lkvzjxoc8j2o3rjso8vjpz8up9up23rj;oasj;lcjzxc09vu923hrkalsia8yxvlziuxhf"
  } 
  
  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper,
  # like if you have constraints or database-specific column types
  # config.active_record.schema_format = :sql

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector

  # Make Active Record use UTC-base instead of local time
  # config.active_record.default_timezone = :utc
  config.time_zone = 'UTC'
  
  # See Rails::Configuration for more options
  
  #config.gem "juggernaut",  :version => '>=0.5.4'
end

# Include your application configuration below
$KCODE = 'u'
require "gettext/rails"

USER_COOKIE_EXPIRATION = 1.day
USER_COOKIE_SECRET = "chatlino_secret"
USER_PASSWORD_SALT = "chatlino_salt"

# XXX: temporary fix for gettext breakage.
module ActionView
  class Base
    delegate :file_exists?, :to => :finder unless respond_to?(:file_exists?)
  end
end
