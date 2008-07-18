set :application, "chatlino"
set :repository,  "http://code.handlino.com/svn/Chatlino/trunk"

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
set :deploy_to, "/home/chatlino"
set :user, "chatlino"
set :password, "3c4v6b"
set :port, "723"
#set :rake, "/opt/local/bin/rake" # Mac
set :rake, "/usr/bin/rake" # Ubuntu Slice

set :group, "chatlino"
set :scm_username, "chatlino" # svn user name
set :scm_password, "chatlino7239"
set :scm_command, "svn"

set :use_sudo, false
ssh_options[:paranoid] = false 
  
# This's because Capistrano will not load environment variables
#default_environment["PATH"] = "/Users/registrano/bin:/opt/local/bin:/usr/local/svn/bin:/bin:/sbin:/usr/bin:/usr/sbin" # Mac
default_environment["PATH"] = "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/bin/X11:/usr/games" # Ubuntu Slice

# If you aren't using Subversion to manage your source code, specify
# your SCM below:
# set :scm, :subversion

role :app, "67.207.129.40"
role :web, "67.207.129.40"
role :db,  "67.207.129.40", :primary => true

namespace :deploy do
 desc "Create database.yml and asset packages for production" 
 task :after_update_code, :roles => [:web] do
   
   db_config = "#{shared_path}/config/database.yml.production"
   run <<-EOF
     cp #{db_config} #{release_path}/config/database.yml
   EOF
      
   run <<-EOF
      ln -s #{shared_path}/upload #{latest_release}/public/upload
   EOF
    
 end
 
 desc "Restart Mongrel"
 task :restart, :roles => [:app] do
   run <<-EOF
     cd #{current_path} && mongrel_rails cluster::restart
   EOF
 end
 
end

desc "Find out svn version on server"
task :what_version, :roles => [:app] do
  stream <<-CMD
  svn info #{current_path}/app
  CMD
end