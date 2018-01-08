class AddSignedInToBusinesses < ActiveRecord::Migration[5.1]
  def change
    add_column :businesses, :signed_in, :date
  end
end
