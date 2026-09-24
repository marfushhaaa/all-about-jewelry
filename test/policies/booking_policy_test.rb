require "test_helper"

class BookingPolicyTest < ActiveSupport::TestCase
  # new?/create? erhalten einen Kurs als Record
  test "create: Gast darf nicht buchen" do
    assert_not BookingPolicy.new(nil, courses(:last_place_course)).create?
  end

  test "create: user, fremder creator und admin dürfen freien fremden Kurs buchen" do
    course = courses(:last_place_course) # gehört creator
    assert BookingPolicy.new(users(:user), course).create?
    assert BookingPolicy.new(users(:creator_two), course).create?
    assert BookingPolicy.new(users(:admin), course).create?
    assert BookingPolicy.new(users(:user), course).new?
  end

  test "create: creator darf eigenen Kurs nicht buchen" do
    assert_not BookingPolicy.new(users(:creator), courses(:last_place_course)).create?
  end

  test "create: ausgebuchter oder bereits gebuchter Kurs wird abgelehnt" do
    assert_not BookingPolicy.new(users(:user), courses(:full_course)).create?
    assert_not BookingPolicy.new(users(:user), courses(:open_course)).create?
  end

  test "create: mit Booking statt Kurs als Record abgelehnt" do
    assert_not BookingPolicy.new(users(:user), bookings(:confirmed)).new?
  end

  test "show: Besitzer und admin" do
    booking = bookings(:confirmed) # gehört user
    assert_not BookingPolicy.new(nil, booking).show?
    assert BookingPolicy.new(users(:user), booking).show?
    assert_not BookingPolicy.new(users(:creator), booking).show?
    assert_not BookingPolicy.new(users(:creator_two), booking).show?
    assert BookingPolicy.new(users(:admin), booking).show?
  end

  test "destroy: nur Besitzer einer bestätigten Buchung" do
    booking = bookings(:confirmed)
    assert_not BookingPolicy.new(nil, booking).destroy?
    assert BookingPolicy.new(users(:user), booking).destroy?
    assert_not BookingPolicy.new(users(:creator), booking).destroy?
    assert_not BookingPolicy.new(users(:creator_two), booking).destroy?
    assert_not BookingPolicy.new(users(:admin), booking).destroy?
  end

  test "destroy: bereits stornierte Buchung kann nicht erneut storniert werden" do
    assert_not BookingPolicy.new(users(:user), bookings(:cancelled)).destroy?
  end
end
