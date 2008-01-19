
require 'juggernaut'
require 'juggernaut_helper'

ActionView::Helpers::AssetTagHelper::register_javascript_include_default('swfobject')
ActionView::Helpers::AssetTagHelper::register_javascript_include_default('juggernaut')

ActionView::Base.send(:include, Juggernaut::JuggernautHelper)

ActionController::Base.class_eval do
  include Juggernaut::RenderExtension
end
