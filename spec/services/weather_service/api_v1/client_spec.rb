require 'rails_helper'


RSpec.describe WeatherService::ApiV1::Client do
  subject { described_class.new }

  temperature = Temperature.new(metric_value: 10.0)
  historical_temperature = 24.times.map { |value| temperature.as_json }

  describe "#get_location_key", vcr: { erb: { temp: temperature } } do
    let(:response) { subject.get_location_key }

    it { expect(response).to eq(temperature.external_location_id) }
  end

  describe "#get_current_temperature", vcr: { erb: { temp: temperature } } do
    let(:response) { subject.get_current_temperature }

    it { expect(response).to eq(temperature.as_json) }
  end

  describe "#get_historical_temperature", vcr: { erb: { temp: temperature } } do
    let(:response) { subject.get_historical_temperature }

    it { expect(response).to eq(historical_temperature) }
  end

  describe "#get_max_temperature", vcr: { erb: { temp: temperature, temp_max: 20.0 } } do
    let(:response) { subject.get_max_temperature }
    
    it { expect(response[:value]).to eq(20.0) }
  end

  describe "#get_min_temperature", vcr: { erb: { temp: temperature, temp_min: 5.0 } } do
    let(:response) { subject.get_min_temperature }

    it { expect(response[:value]).to eq(5.0) }
  end
  
  describe "#get_avg_temperature", vcr: { erb: { temp: temperature, temp_max: 20.0 } } do
    let(:response) { subject.get_avg_temperature }
    
    it { expect(response[:value]).to eq(10.4) }
  end
end
