class AddAbvToBeer < ActiveRecord::Migration[5.0]
  def change
    add_column :beers, :abv, :integer
  end
end
