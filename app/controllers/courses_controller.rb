class CoursesController < ApplicationController
  def index
  end

  def details
    if current_user.blank?
      render plain: '401 Unauthorized', status: :unauthorized
    end
  end
end
