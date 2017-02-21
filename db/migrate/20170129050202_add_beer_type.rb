class AddBeerType < ActiveRecord::Migration[5.0]
  def change
    add_column :beers, :beer_type, :string
  end
end
