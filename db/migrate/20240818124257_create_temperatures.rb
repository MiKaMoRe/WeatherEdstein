class CreateTemperatures < ActiveRecord::Migration[7.1]
  def change
    create_table :temperatures do |t|
      t.float :metric_value,                null: false, default: 12
      t.string :metric_unit,                null: false, default: 'C'
      t.integer :epoch_time,                null: false, default: Time.now.to_i
      t.integer :external_location_id,      null: false, default: 1

      t.timestamps
    end

    add_index :temperatures, [:epoch_time, :external_location_id], unique: true
  end
end
