class CreateExtraDurations < ActiveRecord::Migration[5.1]
  def change
    create_table :extra_durations do |t|
      t.integer :duration
      t.text :duration_desc

      t.timestamps
    end
  end
end
