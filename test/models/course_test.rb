require "test_helper"

class CourseTest < ActiveSupport::TestCase
  # free_places
  test "free_places zählt nur bestätigte Buchungen" do
    assert_equal 9, courses(:open_course).free_places
    assert_equal 0, courses(:full_course).free_places
    assert_equal 1, courses(:last_place_course).free_places
    # stornierte Buchung belegt keinen Platz
    assert_equal 5, courses(:creator_two_course).free_places
  end

  test "free_places ist unendlich ohne Teilnehmerlimit" do
    course = courses(:open_course)
    course.max_participants = nil
    assert_equal Float::INFINITY, course.free_places
  end

  # full?
  test "full? ist true beim ausgebuchten Kurs" do
    assert courses(:full_course).full?
  end

  test "full? ist false bei freien Plätzen oder ohne Limit" do
    assert_not courses(:open_course).full?
    assert_not courses(:last_place_course).full?

    course = courses(:full_course)
    course.max_participants = nil
    assert_not course.full?
  end

  # bookable_by?
  test "bookable_by? ist true für fremden Kurs mit freiem Platz" do
    assert courses(:last_place_course).bookable_by?(users(:user))
  end

  test "bookable_by? ist false für den eigenen Kurs" do
    assert_not courses(:creator_course).bookable_by?(users(:creator))
  end

  test "bookable_by? ist false wenn bereits gebucht" do
    assert_not courses(:open_course).bookable_by?(users(:user))
  end

  test "bookable_by? ist true nach Storno" do
    assert courses(:creator_two_course).bookable_by?(users(:user))
  end

  test "bookable_by? ist false wenn ausgebucht" do
    assert_not courses(:full_course).bookable_by?(users(:user))
  end

  test "bookable_by? ist false für Gäste" do
    assert_not courses(:open_course).bookable_by?(nil)
  end

  # Validierung
  test "end_date muss nach start_date liegen" do
    course = courses(:open_course)
    course.end_date = course.start_date - 1.hour
    assert_not course.valid?
    assert_includes course.errors[:end_date], "muss nach dem Start liegen"
  end

  test "end_date gleich start_date ist ungültig" do
    course = courses(:open_course)
    course.end_date = course.start_date
    assert_not course.valid?
    assert course.errors[:end_date].any?
  end

  test "end_date nach start_date ist gültig" do
    course = courses(:open_course)
    course.end_date = course.start_date + 2.hours
    assert course.valid?
  end
end
