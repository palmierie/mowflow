class AddPositionToScheduledLocation < ActiveRecord::Migration[5.1]
  def change
    add_column :scheduled_locations, :position, :integer
  end
end
