require "test_helper"

class CoursePolicyTest < ActiveSupport::TestCase
  def policy(user, course = courses(:creator_course))
    CoursePolicy.new(user, course)
  end

  test "index und show sind für alle Rollen inkl. Gast erlaubt" do
    [ nil, users(:user), users(:creator), users(:creator_two), users(:admin) ].each do |user|
      assert policy(user).index?, "index? für #{user&.username || 'Gast'}"
      assert policy(user).show?, "show? für #{user&.username || 'Gast'}"
    end
  end

  test "create: nur creator und admin" do
    assert_not policy(nil, Course.new).create?
    assert_not policy(users(:user), Course.new).create?
    assert policy(users(:creator), Course.new).create?
    assert policy(users(:creator_two), Course.new).create?
    assert policy(users(:admin), Course.new).create?
    assert policy(users(:creator), Course.new).new?
  end

  test "update: nur Besitzer und admin" do
    assert_not policy(nil).update?
    assert_not policy(users(:user)).update?
    assert policy(users(:creator)).update?
    assert_not policy(users(:creator_two)).update?, "fremder creator"
    assert policy(users(:admin)).update?
    assert_not policy(users(:creator_two)).edit?
  end

  test "destroy: nur Besitzer und admin" do
    assert_not policy(nil).destroy?
    assert_not policy(users(:user)).destroy?
    assert policy(users(:creator)).destroy?
    assert_not policy(users(:creator_two)).destroy?, "fremder creator"
    assert policy(users(:admin)).destroy?
  end

  test "scope liefert alle Kurse" do
    assert_equal Course.count, CoursePolicy::Scope.new(nil, Course).resolve.count
  end
end
