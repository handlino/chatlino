# Include hook code here

require "ipush"
ActionController::Base.send :include, Ipush

ActionView::Base::load_helpers "#{directory}/lib/helpers/"

