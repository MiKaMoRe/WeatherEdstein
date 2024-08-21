# frozen_string_literal: true

require 'rails_helper'

RSpec.shared_examples 'returns expected response' do
  before { send_request }

  it { expect(response).to have_http_status(:ok) }
  it { expect(response.body).to eq(expected_body.to_json) }
end

RSpec.describe WeathersController, type: :controller do
  let(:weather_service_instance) { WeatherService::ApiV1::Client.new }

  before { allow(WeatherService::ApiV1::Client).to receive(:new).and_return(weather_service_instance) }

  describe 'GET #current' do
    it_behaves_like 'returns expected response'

    let(:temperature) { build(:temperature) }
    let(:expected_body) { temperature }
    let(:send_request) { get :current }

    before { allow(weather_service_instance).to receive(:get_current_temperature).and_return(temperature.as_json) }

    context 'when temperature do not exist' do
      it 'creates new temperature' do
        expect { send_request }.to change(Temperature, :count).by(1)
      end
    end
    
    context 'when temperature exists' do
      before { temperature.save! }
  
      it 'do not creates new temperature' do
        expect { send_request }.not_to change(Temperature, :count)
      end
    end
  end

  describe 'GET #historical' do
    it_behaves_like 'returns expected response'

    let(:send_request) { get :historical }
    let(:historical_temperature) { build_list(:temperature, 24) }
    let(:expected_body) { historical_temperature }

    before do
      historical_temperature_list = historical_temperature.map { |temp| temp.as_json }
      allow(weather_service_instance).to receive(:get_historical_temperature).and_return(historical_temperature_list)
    end

    context 'when temperatures do not exist' do
      it 'creates new temperatures' do
        expect { send_request }.to change(Temperature, :count).by(24)
      end
    end

    context 'when temperatures exists' do
      before { historical_temperature.each { |temp| temp.save! } }

      it 'do not creates new temperature' do
        expect { send_request }.not_to change(Temperature, :count)
      end
    end
  end

  describe 'GET #historical_max' do
    it_behaves_like 'returns expected response'

    let(:temperature) { create(:temperature) }
    let(:expected_body) { temperature }
    let(:send_request) { get :historical_max }

    before { allow(weather_service_instance).to receive(:get_max_temperature).and_return(temperature.as_json) }
  end

  describe 'GET #historical_min' do
    it_behaves_like 'returns expected response'

    let(:temperature) { create(:temperature) }
    let(:expected_body) { temperature }
    let(:send_request) { get :historical_min }

    before { allow(weather_service_instance).to receive(:get_min_temperature).and_return(temperature.as_json) }
  end

  describe 'GET #historical_avg' do
    it_behaves_like 'returns expected response'

    let(:temperature) { create(:temperature) }
    let(:expected_body) { temperature }
    let(:send_request) { get :historical_avg }

    before { allow(weather_service_instance).to receive(:get_avg_temperature).and_return(temperature.as_json) }
  end

  describe 'by_time' do
    it_behaves_like 'returns expected response'

    let(:temperature) { create(:temperature) }
    let(:expected_body) { temperature }
    let(:send_request) { get :by_time, params: { epoch_time: temperature.epoch_time } }
  end
end
