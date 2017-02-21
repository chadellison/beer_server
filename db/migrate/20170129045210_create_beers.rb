class CreateBeers < ActiveRecord::Migration[5.0]
  def change
    create_table :beers do |t|
      t.string  :image
      t.string  :name
      t.string  :type
      t.integer :rating
      t.timestamps
    end
  end
end
