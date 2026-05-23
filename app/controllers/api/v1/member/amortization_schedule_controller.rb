module Api
  module V1
    module Member
      class AmortizationScheduleController < ApplicationController
        before_action :authorize_request

        def index
          loan = Loan.includes(:loan_product).find(params[:loan_id])

          entries = AmortizationScheduleEntry
                      .where(loan_id: loan.id)
                      .order(:due_date)

          total_due = entries.sum(:amount_due)
          total_paid = entries.where(is_paid: true).sum(:amount_due)
          remaining = total_due - total_paid

          render json: {
            loan_id: loan.id,

            # ✅ ADD LOAN PRODUCT
            loan_product: {
              id: loan.loan_product&.id,
              name: loan.loan_product&.name
            },

            summary: {
              total_due: total_due,
              total_paid: total_paid,
              remaining: remaining
            },

            entries: entries.map { |e|
              {
                id: e.id,
                due_date: e.due_date,
                amount_due: e.amount_due,
                principal: e.principal,
                interest: e.interest,
                is_paid: e.is_paid,
                status: e.is_paid ? "paid" : "unpaid",

                # ✅ SAFE PAYMENTS STRUCTURE
                data: {
                  payments: e.data&.dig("payments") || []
                }
              }
            }
          }
        end
      end
    end
  end
end
