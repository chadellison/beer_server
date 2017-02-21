module Api
  module V1
    class BeerTypesController < ApplicationController
      respond_to :json

      def index
        beer_types = Beer.where(approved: true)
                      .select(:beer_type)
                      .distinct.pluck(:beer_type)
                      .unshift("all beers")

        respond_with types: beer_types
      end
    end
  end
end
