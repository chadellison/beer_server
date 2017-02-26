class ApprovedUsersController < ActionController::Base
  def show
    @user = User.find_by(password_digest: params[:token])
    @user.update(approved: true)
    redirect_to ENV["beer_project_host"]
  end
end
