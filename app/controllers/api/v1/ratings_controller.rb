module Api
  module V1
    class RatingsController < Api::V1::BaseController
      before_action :authenticate_with_token, only: [:create]
      respond_to :json

      def create
        beer = Beer.find(params[:beer_id])

        Beer.create_rating(@user, beer, params[:rating])
        respond_with beer, location: nil
      end
    end
  end
end
