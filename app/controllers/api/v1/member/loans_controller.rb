module Api
  module V1
    module Member
      class LoansController < ApplicationController
        before_action :authorize_request

def index
  loans = current_member.loans.includes(:loan_product, :amortization_schedule_entries)
  render json: loans.map { |loan|
    remaining = loan.amortization_schedule_entries.where(is_paid: false).count
    {
      id: loan.id,
      pn_number: loan.pn_number,
      principal: loan.principal,
      interest: loan.interest,
      principal_balance: loan.principal_balance,
      interest_balance: loan.interest_balance,
      status: loan.status,
      cycle: loan.cycle,
      num_installments: loan.num_installments,
      remaining_installments: remaining,        # ← new
      cycle_label: "#{loan.cycle} / #{loan.num_installments}",
      term: loan.term,
      date_released: loan.date_released,
      maturity_date: loan.maturity_date,
      loan_product: {
        id: loan.loan_product_id,
        name: loan.loan_product&.name
      }
    }
  }
end

def applications
  apps = current_member.loan_applications
    .where.not(status: "approved")
    .order(created_at: :desc)

  loan_product_ids = apps.map(&:loan_product_id).uniq
  loan_products = LoanProduct.where(id: loan_product_ids).index_by(&:id)

  render json: apps.map { |app|
    product = loan_products[app.loan_product_id]
    {
      id: app.id,
      status: app.status,
      amount: app.amount,
      term: app.term,
      num_installments: app.num_installments,
      date_applied: app.date_applied,
      reference_number: app.reference_number,
      created_at: app.created_at,
      loan_product: {
        id: app.loan_product_id,
        name: product&.name
      }
    }
  }
end

      end
    end
  end
end
