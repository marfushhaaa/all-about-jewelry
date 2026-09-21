class UsersController < ApplicationController
  allow_unauthenticated_access only: %i[index new create]

  def index
    @users = User.all
  end

  def new
    @user = User.new
  end

  # das erstellen eines Users mit name, username, email, rolle und password
  def create
    @user = User.new(user_params)

    if @user.save
      start_new_session_for @user
      flash[:notice] = "User created successfully"
      redirect_to users_path
    else
      flash[:alert] = "User not created"
      render :new, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:username, :email_address, :role, :password)
  end
end
