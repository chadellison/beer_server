module Api
  module V1
    class BeerTypesController < Api::V1::BaseController
      respond_to :json

      def index
        respond_with types: Beer.fetch_beer_types(params)
      end
    end
  end
end
