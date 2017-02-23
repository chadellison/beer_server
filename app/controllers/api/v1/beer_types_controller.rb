module Api
  module V1
    class BeerTypesController < ApplicationController
      respond_to :json

      def index
        respond_with types: fetch_beer_types(params)
      end
    end
  end
end
