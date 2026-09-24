class AccountsController < ApplicationController
  def show
    @user = Current.user
    @bookings = @user.bookings.confirmed.includes(:course)
    @own_courses = @user.courses.includes(:bookings)
  end

  def edit
    @user = Current.user
  end

  def update
    @user = Current.user
    if @user.update(account_params)
      redirect_to account_path, notice: "Profil gespeichert."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def account_params
    params.require(:user).permit(:username, :email_address)
  end
end