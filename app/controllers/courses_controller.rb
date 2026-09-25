class CoursesController < ApplicationController
  allow_unauthenticated_access only: %i[index show]

  before_action :resume_session, only: %i[index show]
  before_action :set_course, only: %i[show edit update destroy]

  def index
    @courses = Course.order(:start_date)
  end

  def show
  end

  def new
    @course = Course.new
    authorize @course
  end

  def create
    @course = Current.user.courses.new(course_params)
    authorize @course

    if @course.save
      redirect_to @course, notice: "Kurs erstellt."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @course
  end

  def update
    authorize @course

    if @course.update(course_params)
      redirect_to @course, notice: "Kurs gespeichert."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @course
    @course.destroy!
    redirect_to courses_path, status: :see_other, notice: "Kurs gelöscht."
  end

  private

  def set_course
    @course = Course.find(params[:id])
  end

  def course_params
    params.require(:course).permit(:name, :description, :start_date, :end_date, :max_participants)
  end
end
