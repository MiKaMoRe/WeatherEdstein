class Temperature < ApplicationRecord
  validates :epoch_time, uniqueness: { scope: :external_location_id }

  def as_json
    {
      value: metric_value,
      unit: metric_unit,
      epoch_time: epoch_time,
      location_id: external_location_id, 
    }
  end
end
