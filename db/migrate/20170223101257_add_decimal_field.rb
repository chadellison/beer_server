class AddDecimalField < ActiveRecord::Migration[5.0]
  def change
    remove_column :beers, :rating
    add_column :beers, :rating, :decimal
  end
end
