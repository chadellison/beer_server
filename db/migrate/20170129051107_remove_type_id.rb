class RemoveTypeId < ActiveRecord::Migration[5.0]
  def change
    remove_column :beers, :type_id
    add_column :beers, :beer_type, :string
  end
end
