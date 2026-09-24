require "test_helper"

# Direkte Requests auf fremde Datensätze müssen verweigert werden.
class AuthorizationTest < ActionDispatch::IntegrationTest
  test "PATCH und DELETE auf fremden Kurs als normaler user werden verweigert" do
    log_in_as users(:user)
    course = courses(:creator_course)

    patch course_path(course), params: { course: { name: "Gehackt" } }
    assert_redirected_to root_path
    assert_no_difference -> { Course.count } do
      delete course_path(course)
    end
    assert_redirected_to root_path
    assert_not_equal "Gehackt", course.reload.name
  end

  test "PATCH und DELETE auf fremden Kurs als Gast werden verweigert" do
    course = courses(:creator_course)

    patch course_path(course), params: { course: { name: "Gehackt" } }
    assert_redirected_to new_session_path
    assert_no_difference -> { Course.count } do
      delete course_path(course)
    end
    assert_redirected_to new_session_path
  end

  test "DELETE auf fremde Buchung als admin wird verweigert" do
    log_in_as users(:admin)
    booking = bookings(:confirmed)

    delete booking_path(booking)
    assert_redirected_to root_path
    assert booking.reload.confirmed?
  end

  test "GET /admin/users als Nicht-Admin wird verweigert" do
    %i[user creator creator_two].each do |name|
      log_in_as users(name)
      get admin_users_path
      assert_redirected_to root_path, "#{name} darf nicht auf /admin/users"
      assert_equal "Kein Zugriff.", flash[:alert]
      delete session_path
    end
  end
end
