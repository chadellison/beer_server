module Api
  module V1
    class BeersController < Api::V1::BaseController
      before_action :authenticate_with_token, only: [:create]
      before_action :find_or_initialize_beer, only: [:create]
      before_action :filter_beers, only: [:index]
      respond_to :json

      def index
        respond_with beers: @filtered_beers
      end

      def create
        if @beer.save
          Rating.create_with_relationships(@user, @beer, beer_params[:rating])
          respond_with @beer, location: nil
        else
          errors = { errors: @beer.errors }
          respond_with errors, location: nil, status: 422
        end
      end

      private

      def filter_beers
        @filtered_beers = Beer.current_beers(search_params[:current_beers],
                                             search_params[:token])
                              .beer_type(search_params[:type])
                              .beer_name(search_params[:text])
                              .sort_by_criterion(search_params[:sort])
                              .current_page(search_params[:page])
                              .beer_order
      end

      def find_or_initialize_beer
        @beer = Beer.find_or_initialize_by(
          name: beer_params[:name].to_s.downcase,
          beer_type: beer_params[:beer_type].to_s.downcase,
          brand: beer_params[:brand].to_s.downcase
        )

        return @beer unless beer_params[:abv].present? && @beer.abv.nil?
        @beer.abv = beer_params[:abv]
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
