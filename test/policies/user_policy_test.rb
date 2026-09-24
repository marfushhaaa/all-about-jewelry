require "test_helper"

class UserPolicyTest < ActiveSupport::TestCase
  test "index: nur admin" do
    assert_not UserPolicy.new(nil, User).index?
    assert_not UserPolicy.new(users(:user), User).index?
    assert_not UserPolicy.new(users(:creator), User).index?
    assert_not UserPolicy.new(users(:creator_two), User).index?
    assert UserPolicy.new(users(:admin), User).index?
  end

  test "destroy: nur admin, und nicht sich selbst" do
    target = users(:user)
    assert_not UserPolicy.new(nil, target).destroy?
    assert_not UserPolicy.new(users(:creator), target).destroy?
    assert_not UserPolicy.new(users(:creator_two), target).destroy?
    assert_not UserPolicy.new(users(:user), users(:creator)).destroy?
    assert UserPolicy.new(users(:admin), target).destroy?
    assert_not UserPolicy.new(users(:admin), users(:admin)).destroy?
  end

  test "show, create, update sind für alle Rollen verboten (Default)" do
    [ nil, users(:user), users(:creator), users(:creator_two), users(:admin) ].each do |user|
      policy = UserPolicy.new(user, users(:user))
      assert_not policy.show?
      assert_not policy.create?
      assert_not policy.update?
    end
  end
end
