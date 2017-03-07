module Api
  module V1
    class BeersController < Api::V1::BaseController
      before_action :authenticate_with_token, only: [:create]
      respond_to :json

      def index
        respond_with beers: Beer.search(search_params)
      end

      def create
        beer = find_or_initialize_beer

        if beer.save
          Rating.create_with_relationships(@user, beer, beer_params[:rating])
          respond_with beer, location: nil
        else
          errors = { errors: beer.errors }
          respond_with errors, location: nil, status: 422
        end
      end

      private

        def find_or_initialize_beer
          beer = Beer.find_or_initialize_by(name: beer_params[:name].to_s.downcase,
                                            beer_type: beer_params[:beer_type].to_s.downcase)

          beer.abv = beer_params[:abv] if beer_params[:abv].present? && beer.abv.nil?
          beer.brand = beer_params[:brand] if beer_params[:brand].present? && beer.brand.nil?
          beer
        end

        def search_params
          params.permit(:type, :name, :text, :sort, :rating, :current_beers,
                        :token, :page)
        end

        def beer_params
          params.require(:beer).permit(:beer_type, :name, :rating, :abv, :brand)
        end
    end
  end
end
