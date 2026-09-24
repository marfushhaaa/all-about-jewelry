require "test_helper"

class BookingsControllerTest < ActionDispatch::IntegrationTest
  # new
  test "new zeigt Bestätigungsseite" do
    log_in_as users(:user)
    get new_course_booking_path(courses(:last_place_course))
    assert_response :success
    assert_select "h1", text: "Buchung bestätigen"
  end

  test "new für ausgebuchten Kurs wird verweigert" do
    log_in_as users(:user)
    get new_course_booking_path(courses(:full_course))
    assert_redirected_to root_path
  end

  test "new für eigenen Kurs wird verweigert" do
    log_in_as users(:creator)
    get new_course_booking_path(courses(:last_place_course))
    assert_redirected_to root_path
  end

  test "new als Gast leitet zum Login" do
    get new_course_booking_path(courses(:last_place_course))
    assert_redirected_to new_session_path
  end

  # create
  test "create bucht und leitet zur Buchung weiter" do
    log_in_as users(:user)
    assert_difference -> { Booking.count }, +1 do
      post course_booking_path(courses(:last_place_course))
    end
    assert_redirected_to booking_path(Booking.last)
    assert_equal "Buchung bestätigt.", flash[:notice]
  end

  test "create auf bereits gebuchten Kurs wird verweigert" do
    log_in_as users(:user)
    assert_no_difference -> { Booking.count } do
      post course_booking_path(courses(:open_course))
    end
    assert_redirected_to root_path
  end

  test "create auf eigenen Kurs wird verweigert" do
    log_in_as users(:creator)
    assert_no_difference -> { Booking.count } do
      post course_booking_path(courses(:last_place_course))
    end
    assert_redirected_to root_path
  end

  test "create auf unbekannten Kurs liefert 404" do
    log_in_as users(:user)
    post course_booking_path(course_id: 0)
    assert_response :not_found
  end

  # show
  test "show der eigenen Buchung" do
    log_in_as users(:user)
    get booking_path(bookings(:confirmed))
    assert_response :success
    assert_select "h2", text: bookings(:confirmed).course.name
  end

  test "show als admin" do
    log_in_as users(:admin)
    get booking_path(bookings(:confirmed))
    assert_response :success
  end

  test "show einer fremden Buchung wird verweigert" do
    log_in_as users(:creator_two)
    get booking_path(bookings(:confirmed))
    assert_redirected_to root_path
  end

  test "show als Gast leitet zum Login" do
    get booking_path(bookings(:confirmed))
    assert_redirected_to new_session_path
  end

  # destroy
  test "destroy storniert eigene Buchung" do
    log_in_as users(:user)
    booking = bookings(:confirmed)
    delete booking_path(booking)
    assert_redirected_to account_path
    assert_equal "Buchung storniert.", flash[:notice]
    assert booking.reload.cancelled?
  end

  test "destroy einer bereits stornierten Buchung wird verweigert" do
    log_in_as users(:user)
    delete booking_path(bookings(:cancelled))
    assert_redirected_to root_path
  end

  test "destroy einer fremden Buchung wird verweigert" do
    log_in_as users(:creator_two)
    delete booking_path(bookings(:confirmed))
    assert_redirected_to root_path
    assert bookings(:confirmed).reload.confirmed?
  end

  test "destroy als Gast leitet zum Login" do
    delete booking_path(bookings(:confirmed))
    assert_redirected_to new_session_path
    assert bookings(:confirmed).reload.confirmed?
  end
end
