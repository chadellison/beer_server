module Api
  module V1
    class BeersController < ApplicationController
      respond_to :json

      def index
        respond_with beers: Beer.search(beer_params)
      end

      def create
        beer = Beer.new(new_beer_params)
        beer.name = beer.name.downcase if new_beer_params[:name]

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
    end
  end
end
