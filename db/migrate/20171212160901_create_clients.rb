class CreateClients < ActiveRecord::Migration[5.1]
  def change
    create_table :clients do |t|
      t.references :business, foreign_key: true
      t.string :full_name
      t.string :second_full_name
      t.string :email
      t.string :second_email
      t.string :phone
      t.string :second_phone
      t.text :additional_note

      t.timestamps
    end
  end
end
