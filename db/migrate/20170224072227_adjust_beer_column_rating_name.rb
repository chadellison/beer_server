class AdjustBeerColumnRatingName < ActiveRecord::Migration[5.0]
  def change
    remove_column :beers, :rating
    add_column :beers, :average_rating, :decimal
  end
end
