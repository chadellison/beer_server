class ChangeBeerTypeToTypeId < ActiveRecord::Migration[5.0]
  def change
    remove_column :beers, :beer_type
    add_column :beers, :type_id, :integer
  end
end
