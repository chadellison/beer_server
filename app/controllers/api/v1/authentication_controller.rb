class Api::V1::AuthenticationController < ApplicationController
  respond_to :json

  def create
    user = User.find_by(email: login_params[:email])
    if user && user.authenticate(login_params[:password]) && user.approved
      new_token = BCrypt::Password.create("password")
      user.update(password_digest: new_token)
      respond_with user, location: nil, status: 200
    else
      error = ActiveRecord::RecordNotFound
      message = { errors: "Invalid Credentials" }
      respond_with message, location: nil, status: 404
    end
  end

  private

  def login_params
    params.require(:credentials).permit(:email, :password)
  end
end
