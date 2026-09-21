class Course < ApplicationRecord
  belongs_to :creator, class_name: "User"
  has_many :bookings, dependent: :destroy
end
