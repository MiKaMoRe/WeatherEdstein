FactoryBot.define do
  sequence(:epoch_time) { |n| Time.now.to_i + n } 

  factory :temperature do
    metric_value { 17.3 }
    metric_unit { 'C' }
    epoch_time
    external_location_id { 1000 }
  end
end
