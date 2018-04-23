class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.string :name
      t.string :image
      t.string :title
      t.string :link
      t.text :body
      t.integer :price
      t.timestamps
    end
  end
end
