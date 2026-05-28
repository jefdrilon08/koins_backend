module Api
  module V1
    module Member
      class LoanProductsController < ApplicationController
        before_action :authorize_request

        def index
          products = ::LoanProduct
            .where(is_active: true)
            .where.not(id: blocked_loan_product_ids)
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

        private

        def blocked_loan_product_ids
          active_loans = current_member.loans.where(status: 'active')
          return [] if active_loans.none?

          blocked = []

          active_loans.each do |loan|
            unpaid_count = AmortizationScheduleEntry
              .where(loan_id: loan.id, is_paid: false)
              .count

            blocked << loan.loan_product_id if unpaid_count <= 5
          end

          blocked
        end
      end
    end
  end
end
