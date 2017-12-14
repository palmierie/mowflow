class CreateBusinesses < ActiveRecord::Migration[5.1]
  def change
    create_table :businesses do |t|
      t.string :name
      t.references :user, foreign_key: true
      t.string :password_digest

      t.timestamps
    end
  end
end
