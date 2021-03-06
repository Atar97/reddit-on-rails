# == Schema Information
#
# Table name: users
#
#  id              :bigint(8)        not null, primary key
#  username        :string           not null
#  password_digest :string           not null
#  session_token   :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class User < ApplicationRecord
  validates :username, :password_digest, :session_token, presence: true
  validates :password, length: {minimum: 6, allow_nil: true}
  before_validation :ensure_session_token
  
  attr_reader :password
  
  has_many :subs, 
    foreign_key: :moderator_id,
    class_name: :Sub
    
  has_many :posts,
    foreign_key: :author_id,
    class_name: :Post
  
  def password=(pw)
    @password = pw
    self.password_digest = BCrypt::Password.create(pw)
  end 
  
  def is_password?(pw)
    BCrypt::Password.new(password_digest).is_password?(pw)
  end 
  
  def self.find_by_credentials(username, pw)
    user = User.find_by(username: username)
    if user && user.is_password?(pw)
      user 
    else 
      nil
    end 
  end 
  
  def self.session_token
    SecureRandom.urlsafe_base64
  end 
  
  def ensure_session_token
    self.session_token ||= User.session_token
  end 
  
  def reset_session_token!
    self.session_token = User.session_token
    self.save
    session_token
  end 
    
end
