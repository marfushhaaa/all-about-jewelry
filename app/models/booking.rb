class Booking < ApplicationRecord
  belongs_to :user
  belongs_to :course
  enum :status, { confirmed: "confirmed", cancelled: "cancelled" }
end
