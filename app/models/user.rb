class User < ApplicationRecord
  has_secure_password
  validates :username, presence: true, uniqueness: true
  validates :email_address, presence: true, uniqueness: true

  has_many :sessions, dependent: :destroy
  has_many :courses, foreign_key: :creator_id, dependent: :destroy
  has_many :bookings, dependent: :destroy
  
  enum :role, { user: "user", creator: "creator" }

  normalizes :email_address, with: ->(e) { e.strip.downcase }
end
