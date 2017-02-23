module Api
  module V1
    class BeerTypesController < ApplicationController
      respond_to :json

      def index
        Beer.fetch_beer_types(params)
        beer_types = Beer.where(approved: true)
                      .select(:beer_type)
                      .distinct.pluck(:beer_type)
                      .unshift("all types")
        respond_with types: beer_types
      end
    end
  end
end
