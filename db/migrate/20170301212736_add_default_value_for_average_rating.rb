class AddDefaultValueForAverageRating < ActiveRecord::Migration[5.0]
  def change
    remove_column :beers, :average_rating
    add_column :beers, :average_rating, :decimal, default: 0
  end
end
