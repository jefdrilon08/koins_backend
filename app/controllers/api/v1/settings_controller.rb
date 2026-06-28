class Api::V1::SettingsController < ApplicationController
  def index
    render json: {
      cash_flow_threshold: ENV.fetch('CASH_FLOW_THRESHOLD', 25_000).to_i
    }
  end
end
