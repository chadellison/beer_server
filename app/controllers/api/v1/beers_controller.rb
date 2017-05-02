module Api
  module V1
    class BeersController < Api::V1::BaseController
      before_action :authenticate_with_token, only: [:create]
      before_action :find_or_initialize_beer, only: [:create]
      respond_to :json

      def index
        respond_with beers: filter_beers
      end

      def create
        if @beer.save
          Rating.create_with_relationships(@user, @beer, beer_params[:rating])
          respond_with @beer, location: nil
        else
          errors = @beer.errors.map { |key, value| "#{key} #{value}" }.join("\n")
          render json: { errors: errors}, status: 422
        end
      end

      private

      def filter_beers
        relation = Beer.current_beers(search_params[:current_beers],
                                      search_params[:token])
        unless ['all types', ''].include?(search_params[:type])
          relation = relation.beer_type(search_params[:type])
        end
        if search_params[:text].present?
          relation = relation.beer_name(search_params[:text])
        end
        relation = relation.sort_by_criterion(search_params[:sort])
        relation = relation.current_page(search_params[:page],
                                         search_params[:per_page])
        relation.beer_order.beer_limit(params[:per_page])
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
                      :token, :page, :per_page)
      end

      def beer_params
        params.require(:beer).permit(:beer_type, :name, :rating, :abv, :brand)
      end
    end
  end
end
