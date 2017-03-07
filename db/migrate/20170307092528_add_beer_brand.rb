class AddBeerBrand < ActiveRecord::Migration[5.0]
  def change
    add_column :beers, :brand, :string
  end
end
