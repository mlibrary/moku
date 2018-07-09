class CreateThings < ActiveRecord::Migration[5.1]
  def change
    create_table :things do |t|
      t.string :name
      t.string :title
      t.text :content
      t.text :more_stuff
      t.boolean :admin

      t.timestamps
    end
  end
end
