class CreateScheduleHistories < ActiveRecord::Migration[5.1]
  def change
    create_table :schedule_histories do |t|
      t.references :business, foreign_key: true
      t.datetime :date
      t.text :mow_list

      t.timestamps
    end
  end
end
