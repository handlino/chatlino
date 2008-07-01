ActionController::Routing::Routes.draw do |map|
  # The priority is based upon order of creation: first created -> highest priority.

  map.open_id_complete 'session', :controller => "sessions",:action => "create", :requirements => { :method => :get }
  map.open_id_complete_on_user '/users/add_openid', :controller => 'openids', :action => "create", :requirements => { :method => :get }
  
  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  map.login '/login', :controller => 'sessions', :action => 'new'
  map.register '/register', :controller => 'users', :action => 'create'
  map.signup '/signup', :controller => 'users', :action => 'new'

  map.resources :users do |user|
    user.resources :openids
    user.resource :icon, :controller => 'user_icons'
  end
  map.resource :session

  map.resources :chatrooms
 
  map.connect '/chat/:action/:id', :controller => "chat"
  
  map.with_options :controller => 'chatrooms' do |m|
    m.chatroom_say '/chatrooms/:id/say', :action => "say"
    m.chatroom_join '/chatrooms/:id/join', :action => "join"
    m.chatroom_leave '/chatrooms:/id/leave', :action => "leave"
    m.chatroom_refresh_info '/chatrooms/:id/refresh_info', :action => "refresh_info"
    m.chatroom_change_subject '/chatrooms/:id/change_subject', :action => "change_subject"
    m.chatroom_ping '/chatrooms/:id/ping', :action => "ping"
  end

  map.connect '/chatroom/:action/:id', :controller => "chatroom"
  
  # Sample of regular route:
  # map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  # map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  map.with_options :controller => 'page' do |page|
    page.about '/about', :action => "about"
    page.contact '/contact',:action => "contact"
    page.help "/help", :action => "help"
    page.tos "/tos", :action => "tos"
    page.privacy "/privacy", :action => "privacy"
    page.error "/page/500", :action => "500"
    page.not_found "/page/404", :action => "404"
  end
  
  # You can have the root of your site routed by hooking up ''
  # -- just remember to delete public/index.html.
  map.root :controller => "chatroom", :action => "index"

  # Install the default route as the lowest priority.
  #map.connect ':controller/:action/:id.:format'
  #map.connect ':controller/:action/:id'
end
