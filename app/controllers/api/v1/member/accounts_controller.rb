module Api
  module V1
    module Member
      class AccountsController < ApplicationController
        before_action :authorize_request

        def index
          accounts = ::MemberAccount
            .where(
              member_id: @current_member.id,
              account_type: "SAVINGS"
            )

          render json: serialize(accounts)
        end

        def equity
          accounts = ::MemberAccount
            .where(
              member_id: @current_member.id,
              account_type: "EQUITY"
            )
            .order(created_at: :desc)

          render json: accounts.map { |account|
            {
              id: account.id,
              account_type: account.account_type,
              account_subtype: account.account_subtype,
              balance: account.balance,
              equity_value: account.data&.dig("equity_value"),
              status: account.status,
              created_at: account.created_at
            }
          }
        end

        private

        def serialize(accounts)
          accounts.map do |account|
            {
              id: account.id,
              account_type: account.account_type,
              account_subtype: account.account_subtype,
              account_number: account.data&.dig("account_numbers", 0),
              balance: account.balance,
              maintaining_balance: account.maintaining_balance,
              status: account.status
            }
          end
        end
      end
    end
  end
end
