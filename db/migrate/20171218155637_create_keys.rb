class CreateKeys < ActiveRecord::Migration[5.1]
  def change
    create_table :keys do |t|
      t.string :name
      t.text :key

      t.timestamps
    end
  end
end
