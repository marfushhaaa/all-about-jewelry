class Admin::UsersController < ApplicationController
  def index
    authorize User, :index?
    @users = User.all
  end
end
