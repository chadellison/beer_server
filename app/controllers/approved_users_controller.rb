class ApprovedUsersController < ActionController::Base
  def show
    @user = User.find(params[:id])
    @user.update(approved: true)
    render :show
  end
end
