# app/controllers/api/v1/member/loan_installment_options_controller.rb
module Api
  module V1
    module Member
      class LoanInstallmentOptionsController < ApplicationController
        before_action :authorize_request

        WEEKLY_OPTIONS = [15, 25, 35, 50].freeze

        def index
          options = WEEKLY_OPTIONS.map do |weeks|
            {
              label: "#{weeks} weeks",
              value: weeks.to_s
            }
          end

          render json: options
        end
      end
    end
  end
end
