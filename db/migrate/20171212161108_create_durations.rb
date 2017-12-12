class CreateDurations < ActiveRecord::Migration[5.1]
  def change
    create_table :durations do |t|
      t.integer :duration
      t.text :duration_desc

      t.timestamps
    end
  end
end
