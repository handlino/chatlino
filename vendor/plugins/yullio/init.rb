class ActionController::Base
  def self.yullio_page_width(x)
    self.class_eval "def yullio_page_width; \"#{x.to_s}\"; end"
  end
  
  def self.yullio_column_template(x)
    self.class_eval "def yullio_column_template; \"#{x.to_s.gsub(/_/, '-')}\"; end"
  end
  
  yullio_page_width(:doc)
  yullio_column_template(:yui_t1)

  helper_method :yullio_page_width, :yullio_column_template
end
