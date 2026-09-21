class CoursesController < ApplicationController
  allow_unauthenticated_access only: %i[index]

  def index
  end

  def details
    if current_user.blank?
      render plain: '401 Unauthorized', status: :unauthorized
    end
  end
end
