require "test_helper"

class BookingServiceTest < ActiveSupport::TestCase
  test "bucht den letzten freien Platz, danach ist der Kurs voll" do
    course = courses(:last_place_course)
    assert_equal 1, course.free_places

    booking = assert_difference -> { Booking.count }, +1 do
      BookingService.book!(course, users(:user))
    end

    assert booking.confirmed?
    assert_equal users(:user), booking.user
    assert course.reload.full?
    assert_equal 0, course.free_places
  end

  test "wirft CourseFull bei vollem Kurs" do
    assert_raises(BookingService::CourseFull) do
      BookingService.book!(courses(:full_course), users(:user))
    end
  end

  test "zweite Person bekommt den letzten Platz nicht mehr" do
    course = courses(:last_place_course)
    BookingService.book!(course, users(:user))

    assert_raises(BookingService::CourseFull) do
      BookingService.book!(course, users(:admin))
    end
  end

  test "Neubuchung nach Storno reaktiviert die bestehende Buchung" do
    cancelled = bookings(:cancelled)

    booking = assert_no_difference -> { Booking.count } do
      BookingService.book!(cancelled.course, cancelled.user)
    end

    assert_equal cancelled.id, booking.id
    assert cancelled.reload.confirmed?
  end

  # Transaktion: bei CourseFull darf nichts in der DB landen
  test "bei CourseFull wird keine Buchung gespeichert" do
    course = courses(:full_course)

    assert_no_difference -> { Booking.count } do
      assert_no_difference -> { course.confirmed_bookings.count } do
        assert_raises(BookingService::CourseFull) { BookingService.book!(course, users(:user)) }
      end
    end
    assert_not Booking.exists?(course: course, user: users(:user))
  end

  test "bei CourseFull bleibt eine stornierte Buchung storniert" do
    course = courses(:full_course)
    cancelled = Booking.create!(course: course, user: users(:user), status: "cancelled")

    assert_raises(BookingService::CourseFull) { BookingService.book!(course, users(:user)) }
    assert cancelled.reload.cancelled?
  end
end
