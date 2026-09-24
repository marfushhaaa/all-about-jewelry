require "test_helper"

class BookingTest < ActiveSupport::TestCase
  test "doppelte bestätigte Buchung wird abgelehnt" do
    existing = bookings(:confirmed)
    duplicate = Booking.new(user: existing.user, course: existing.course, status: "confirmed")

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:user_id], "hat diesen Kurs bereits gebucht"
  end

  test "Buchung eines anderen Kurses ist gültig" do
    booking = Booking.new(user: users(:user), course: courses(:last_place_course), status: "confirmed")
    assert booking.valid?
  end

  test "stornierte Buchung blockiert die Validierung nicht" do
    cancelled = bookings(:cancelled)
    booking = Booking.new(user: cancelled.user, course: cancelled.course, status: "confirmed")
    assert booking.valid?
  end
end
