module Api
  module V1
    module Member

      class TransactionsController < ApplicationController

        before_action :authorize_request

        def index

          account =
            ::MemberAccount.find(
              params[:account_id]
            )

          # SECURITY CHECK
          unless
            account.member_id ==
            @current_member.id

            return render json: {
              error: "Unauthorized"
            },
            status: :unauthorized
          end

          transactions =
            ::AccountTransaction
              .where(
                subsidiary_id:
                  account.id
              )
              .order(
                transacted_at:
                  :desc
              )
              .limit(10)

          render json:
            transactions.map { |t|

              {
                id: t.id,

                amount: t.amount,

                transaction_type:
                  t.transaction_type,

                status: t.status,

                transacted_at:
                  t.transacted_at,

                beginning_balance:
                  t.data&.dig(
                    "beginning_balance"
                  ),

                ending_balance:
                  t.data&.dig(
                    "ending_balance"
                  ),

                is_interest:
                  t.data&.dig(
                    "is_interest"
                  ),

                is_adjustment:
                  t.data&.dig(
                    "is_adjustment"
                  ),

                is_fund_transfer:
                  t.data&.dig(
                    "is_fund_transfer"
                  ),

                is_loan_payment:
                  t.data&.dig(
                    "is_for_loan_payments"
                  )
              }
            }

        end
      end
    end
  end
end
