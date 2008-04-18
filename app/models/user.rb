# == Schema Information
# Schema version: 3
#
# Table name: user
#
#  id              :integer(11)     not null, primary key
#  nickname        :string(45)      default(""), not null
#  user_name       :string(45)      default(""), not null
#  password        :string(45)      default(""), not null
#  email           :string(100)     
#  create_date     :datetime        
#  agree_term      :string(1)       
#  suspend         :string(1)       
#  country_id      :string(2)       
#  last_login      :datetime        
#  photo_path      :string(128)     default("/images/buddyicon.jpg")
#  openid_url      :string(255)     
#  email_confirmed :boolean(1)      
#  last_seen       :datetime        
#

require "digest/sha1"

class User < ActiveRecord::Base
  set_table_name :user

  before_create :crypt_password

#   validates_uniqueness_of :email, :on=>:create
#   validates_length_of :password, :within => 5..40
#   validates_confirmation_of :password, :on=>:create

  has_one :confirmation

  has_and_belongs_to_many :chatrooms

  def self.admin
    User.find(1)
  end

  def number_of_unread_inbox_messages
    inbox_messages.count(:all, :conditions=>{:has_read=>false})
  end

  def chatroom
    Chatroom.find_first(["user_id = ?", self.id])
  end

  def chatrooms
    Chatroom.find(:all, :conditions => ["user_id = ?", self.id])
  end

  def is_owner_of(chatroom)
    chatroom.owner == self
  end

  def shortname
    name = nickname.blank? ? "Chatter #{id}" : nickname
    return name.gsub(/(^https?:\/\/|\/$)/, '')
  end

  def is_contact_of?(another_user)
    another_user.contacts.include? self
  end

  def has_contact?(another_user)
    self.contacts.include? another_user
  end

  def self.guest
    User.new
  end

  def self.get(openid_url)
    find_first(["openid_url = ?", openid_url])
  end

  def self.latest_registered(limit=5)
    User.find(:all, :order=>"id DESC", :limit=>limit)
  end

  def is_guest?
    !self.id
  end

  def self.authenticate(login_name, password)
    if u = find(:first, :conditions=>{:email=>login_name, :password=>sha(password)})
      u.last_login = Time.now
      u.save
    end
    u
  end

  def validate
    return true

    # is it a valid e-mail address?
    if !(email =~ /^[A-Z0-9._%-]+@[A-Z0-9.-]+\.[A-Z]{2,4}$/i)
      errors.add(:email, _("is not a valid email address"))
    end

    # the user must agree to the Terms and Conditions
    if agree_term != 'y'
      errors.add(:agree_term, _("must be checked"))
    end

    # if nickname is not blank, check if it's unique
    if !nickname.blank?
      u = User.find(:first, :conditions=>{:nickname => nickname})
      if u && u.id != id
        errors.add(:nickname, _("must be unique"))
      end
    end
  end

  def change_password(password)
    self.password = self.class.sha(password)
  end

  def password_confirmation
  end

  protected
  def before_create
    self.create_date = Time.now
  end

  def crypt_password
    write_attribute("password", self.class.sha(password))
  end

  def self.sha(pass)
    Digest::SHA1.hexdigest("#{USER_PASSWORD_SALT}#{pass}")
  end
end
