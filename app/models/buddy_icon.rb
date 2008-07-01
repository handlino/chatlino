class BuddyIcon < ActiveRecord::Base
  belongs_to :user
  
  has_attachment :content_type => :image, 
                 :storage => :file_system, 
                 :path_prefix => 'public/upload/images',
                 :max_size => 500.kilobytes, 
                 :resize_to => [80,80],
                 :thumbnails => { :small => [32,32], :tiny => [16,16] }

  validates_as_attachment

end
