require 'rails_helper'

RSpec.describe Temperature, type: :model do
  it { should validate_uniqueness_of(:epoch_time).scoped_to(:external_location_id) }
end
