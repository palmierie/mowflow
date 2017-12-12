class CreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t|
      t.string :email
      t.string :password_digest
      t.string :first_name
      t.string :last_name
      t.references :business, foreign_key: true
      t.boolean :admin

      t.timestamps
    end
  end
end
