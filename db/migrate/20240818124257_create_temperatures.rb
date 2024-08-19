class CreateTemperatures < ActiveRecord::Migration[7.1]
  def change
    create_table :temperatures do |t|
      t.integer :metric_value,  null: false
      t.string :metric_unit,    null: false
      t.integer :epoch_time,                null: false
      t.integer :external_location_id,      null: false

      t.timestamps
    end

    add_index :temperatures, [:epoch_time, :external_location_id], unique: true
  end
end
