module Api
  module V1
    module Member
      class LoansController < ApplicationController
        before_action :authorize_request

        def index
  loans = current_member.loans.includes(:loan_product)

  render json: loans.map { |loan|
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
        
      end
    end
  end
end
