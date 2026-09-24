# app/controllers/bookings_controller.rb
class BookingsController < ApplicationController
  before_action :set_course, only: %i[new create]

  # Bestätigungsseite
  def new
    authorize @course, :new?, policy_class: BookingPolicy
  end

  def create
    authorize @course, :create?, policy_class: BookingPolicy
    @booking = BookingService.book!(@course, Current.user)
    redirect_to @booking, notice: "Buchung bestätigt."
  rescue BookingService::CourseFull
    redirect_to @course, alert: "Der Kurs ist inzwischen ausgebucht."
  rescue ActiveRecord::RecordInvalid
    redirect_to @course, alert: "Du hast diesen Kurs bereits gebucht."
  end

  # Thank-You / Detailansicht der Buchung
  def show
    @booking = Booking.find(params[:id])
    authorize @booking
  end

  def destroy
    @booking = Booking.find(params[:id])
    authorize @booking
    @booking.update!(status: "cancelled")
    redirect_to account_path, status: :see_other, notice: "Buchung storniert."
  end

  private

  def set_course
    @course = Course.find(params[:course_id])
  end
end