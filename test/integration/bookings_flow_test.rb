require "test_helper"

class BookingsFlowTest < ActionDispatch::IntegrationTest
  test "Buchung eines ausgebuchten Kurses schlägt fehl" do
    log_in_as users(:user)

    assert_no_difference -> { Booking.count } do
      post course_booking_path(courses(:full_course))
    end
    assert_redirected_to root_path
    assert_equal "Kein Zugriff.", flash[:alert]
  end

  test "Gast kann nicht buchen" do
    assert_no_difference -> { Booking.count } do
      post course_booking_path(courses(:last_place_course))
    end
    assert_redirected_to new_session_path
  end

  test "Neubuchung nach Storno" do
    log_in_as users(:user)
    cancelled = bookings(:cancelled)

    post course_booking_path(cancelled.course)
    assert_redirected_to booking_path(cancelled)
    assert cancelled.reload.confirmed?
  end
end
