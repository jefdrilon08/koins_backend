module Api
  module V1
    module Member
      class LoanProductsController < ApplicationController
        before_action :authorize_request

        def index
          products = ::LoanProduct
            .where(is_active: true)
            .order(:priority)

          render json: products.map { |p|
            {
              id: p.id,
              name: p.name,
              min_loan_amount: p.min_loan_amount,
              max_loan_amount: p.max_loan_amount,
              denomination: p.denomination,
              monthly_interest_rate: p.monthly_interest_rate
            }
          }
        end
      end
    end
  end
end
