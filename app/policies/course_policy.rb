# app/policies/course_policy.rb
class CoursePolicy < ApplicationPolicy
  def index?
    true                                    # alle, auch Gäste
  end

  def show?
    true
  end

  def create?
    user&.creator? || user&.admin?
  end

  def new?
    create?
  end

  def update?
    owner? || user&.admin?
  end

  def edit?
    update?
  end

  def destroy?
    owner? || user&.admin?
  end

  private

  def owner?
    user.present? && record.creator_id == user.id
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.all
    end
  end
end