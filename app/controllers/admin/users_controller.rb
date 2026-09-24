class Admin::UsersController < ApplicationController
  before_action :set_user, only: :destroy

  def index
    authorize User, :index?
    @users = User.all
    @audits = Audited::Audit.order(created_at: :desc).includes(:user, :auditable).limit(50)
  end

  def destroy
    authorize @user, :destroy?
    @user.destroy!
    redirect_to admin_users_path, status: :see_other, notice: "Benutzer gelöscht."
  rescue ActiveRecord::InvalidForeignKey
    redirect_to admin_users_path, alert: "Benutzer hat noch Kurse oder Buchungen."
  end

  private

  def set_user
    @user = User.find(params[:id])
  end
end
