require "test_helper"

class AuditLogTest < ActionDispatch::IntegrationTest
  test "Kurs-Erstellung erzeugt Audit mit Benutzer" do
    log_in_as users(:creator)

    assert_difference -> { Audited::Audit.count }, +1 do
      post courses_path, params: { course: {
        name: "Neuer Kurs", description: "Test",
        start_date: 5.days.from_now, end_date: 6.days.from_now, max_participants: 3
      } }
    end
    course = Course.last
    assert_redirected_to course_path(course)

    audit = Audited::Audit.last
    assert_equal course, audit.auditable
    assert_equal "create", audit.action
    assert_equal users(:creator), audit.user
  end

  test "Buchung erzeugt Audit mit Benutzer" do
    log_in_as users(:user)

    assert_difference -> { Audited::Audit.count }, +1 do
      post course_booking_path(courses(:last_place_course))
    end

    audit = Audited::Audit.last
    assert_equal Booking.last, audit.auditable
    assert_equal "create", audit.action
    assert_equal users(:user), audit.user
  end

  test "Storno erzeugt Update-Audit mit Benutzer" do
    log_in_as users(:user)

    assert_difference -> { Audited::Audit.count }, +1 do
      delete booking_path(bookings(:confirmed))
    end

    audit = Audited::Audit.last
    assert_equal "update", audit.action
    assert_equal users(:user), audit.user
  end
end
