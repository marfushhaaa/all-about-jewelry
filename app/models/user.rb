class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :courses, foreign_key: :creator_id, dependent: :destroy
  has_many :bookings, dependent: :destroy
  
  enum :role, { user: "user", creator: "creator" }

  normalizes :email_address, with: ->(e) { e.strip.downcase }
end
