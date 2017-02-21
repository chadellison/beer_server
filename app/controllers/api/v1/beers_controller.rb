module Api
  module V1
    class BeersController < ApplicationController
      before_filter :authenticate_with_token, only: [:create]
      respond_to :json

      def index
        respond_with beers: Beer.search(beer_params)
      end

      def create
        beer = Beer.find_or_initialize_by(name: new_beer_params[:name].to_s.downcase,
                                          beer_type: new_beer_params[:beer_type])

        if beer.save
          respond_with beer, location: nil
        else
          errors = { errors: beer.errors }
          respond_with errors, location: nil, status: 422
        end
      end

      private

        def beer_params
          params.permit(:type, :name, :text, :sort, :rating)
        end

        def new_beer_params
          params.require(:beer).permit(:beer_type, :name, :rating)
        end

        def authenticate_with_token
          unless User.find_by(password_digest: params[:token]).present?
            return raise ActiveRecord::RecordNotFound
          end
        end
    end
  end
end
