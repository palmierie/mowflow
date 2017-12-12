class CreateScheduledLocations < ActiveRecord::Migration[5.1]
  def change
    create_table :scheduled_locations do |t|
      t.references :client, foreign_key: true
      t.references :business, foreign_key: true
      t.boolean :depot
      t.text :location_desc
      t.string :street_address
      t.string :city
      t.string :state
      t.string :zip
      t.string :google_place_id
      t.string :coordinates
      t.date :start_season
      t.date :end_season
      t.string :day_of_week
      t.integer :mow_frequency
      t.date :date_mowed
      t.date :next_mow_date
      t.references :duration, foreign_key: true
      t.references :extra_duration, foreign_key: true
      t.text :user_notes
      t.text :special_job_notes

      t.timestamps
    end
  end
end
