# app/models/booking.rb
class Booking < ApplicationRecord
  belongs_to :user
  belongs_to :course

  enum :status, { confirmed: "confirmed", cancelled: "cancelled" }

  validates :user_id, uniqueness: {
    scope: :course_id,
    conditions: -> { where(status: "confirmed") },
    message: "hat diesen Kurs bereits gebucht"
  }
end