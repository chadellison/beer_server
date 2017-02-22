module Api
  module V1
    class UsersController < ApplicationController
      respond_to :json

      def create
        user = User.new(user_params)
        if user.save
          NewUserMailer.welcome(user, "#{ENV["host"]}/approved_users/#{user.password_digest}")
            .deliver_later

          respond_with user, location: nil
        else
          errors = { errors: user.errors }
          respond_with errors, location: nil, status: 404
        end
      end

      private

      def user_params
        params.require(:user).permit(:email, :password, :first_name, :last_name)
      end
    end
  end
end
