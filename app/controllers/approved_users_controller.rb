class ApprovedUsersController < ActionController::Base
  def show
    @user = User.find_by(password_digest: params[:id])
    user.update(approved: true)
    render :show
  end
end
