class ApprovedUsersController < ActionController::Base
  protect_from_forgery with: :exception

  def show
    @user = User.find_by(password_digest: params[:token])
    @user.update(approved: true)
    redirect_to ENV["beer_project_host"] + "?approved=true"
  end
end
