class AddApprovedFieldToBeers < ActiveRecord::Migration[5.0]
  def change
    add_column :beers, :approved, :boolean, default: false
  end
end
