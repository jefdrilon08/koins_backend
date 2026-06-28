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
        
        def insurance
          accounts = ::MemberAccount
            .where(
              member_id: @current_member.id,
              account_type: "INSURANCE"
            ).where("balance > 0")
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

        def insurance_info
          record = MembershipPaymentRecord
            .where(
              member_id: @current_member.id,
              membership_type: "Insurance",
              status: "paid"
            )
            .order(date_paid: :asc)
            .first

          render json: {
            insurance_status: @current_member.insurance_status,
            membership_date: record&.date_paid,
            membership_name: record&.membership_name,
          }
        end
        
        def insurance_status
  account = ::MemberAccount.find(params[:account_id])

  unless account.member_id == @current_member.id
    return render json: { error: "Unauthorized" }, status: :unauthorized
  end

  member        = @current_member
  member_data   = (member.data || {}).with_indifferent_access
  current_date  = Date.today

  # ── Recognition date (with reinstatement logic) ──────────────────
  reinstatement       = member_data[:reinstatement]
  data_date_stop      = reinstatement&.dig(:date_stop).try(:to_date)
  data_reinst_date    = reinstatement&.dig(:reinstatement_date).try(:to_date)

  recognition_date = member_data[:recognition_date].try(:to_date)

  if data_reinst_date.present? && data_date_stop.present?
    num_days = (current_date - data_reinst_date).to_i
  else
    recognition_date ||= member.membership_payment_records
      .where(
        membership_type: ["Insurance", "Cooperative"],
        membership_name: ["K-MBA", "K-KOOP"]
      ).first.try(:date_paid)
    num_days = recognition_date ? (current_date - recognition_date).to_i : 0
  end

  num_weeks = (num_days / 7).to_i + 1

  # ── Transactions ─────────────────────────────────────────────────
  transactions = ::AccountTransaction
    .where(subsidiary_id: account.id)
    .order(transacted_at: :asc)

  latest_transaction      = transactions.last
  latest_transaction_date = latest_transaction&.transacted_at&.to_date
  current_balance         = account.balance.to_f

  # ── Default periodic payment by subtype ──────────────────────────
  default_payment = case account.account_subtype
                    when "Retirement Fund"     then 5.0
                    when "Life Insurance Fund" then 15.0
                    when "K-BENTE"             then 20.0
                    when "K-KALINGA"           then 50.0
                    else                            20.0
                    end

  # ── Coverage date ─────────────────────────────────────────────────
  coverage_date = if data_reinst_date.present? && data_date_stop.present?
    data_reinst_date + ((current_balance / default_payment) * 7).to_i
  elsif recognition_date
    recognition_date + ((current_balance / default_payment).to_i).weeks
  else
    nil
  end

  # ── Amounts ───────────────────────────────────────────────────────
  insured_amount     = num_weeks * default_payment
  amt_past_due       = (current_balance - insured_amount) * -1
  num_weeks_past_due = (amt_past_due / default_payment).to_i

  # ── Days lapsed ───────────────────────────────────────────────────
  days_lapsed = latest_transaction_date.present? ? (current_date - latest_transaction_date).to_i : 999

  # ── Status ────────────────────────────────────────────────────────
  status = if days_lapsed <= 45 && current_balance > insured_amount
    "advanced"
  elsif days_lapsed >= 45 && current_balance > insured_amount
    "advanced"
  elsif days_lapsed > 45 && current_balance < insured_amount
    "lapsed"
  elsif days_lapsed <= 45 && current_balance < insured_amount && amt_past_due >= 97
    "lapsed"
  elsif days_lapsed <= 45 && current_balance < insured_amount && amt_past_due < 97
    "past due"
  else
    "normal"
  end

  # ── Length of membership ──────────────────────────────────────────
  length_of_membership = if recognition_date
    years  = current_date.year  - recognition_date.year
    months = current_date.month - recognition_date.month
    if months < 0
      years  -= 1
      months += 12
    end
    parts = []
    parts << "#{years} #{years == 1 ? 'Year' : 'Years'}"     if years  > 0
    parts << "#{months} #{months == 1 ? 'Month' : 'Months'}" if months > 0
    parts.join(", ")
  else
    "—"
  end

  render json: {
    recognition_date:          recognition_date&.strftime("%B %d, %Y"),
    length_of_membership:      length_of_membership,
    current_date:              current_date.strftime("%B %d, %Y"),
    coverage_date:             coverage_date&.strftime("%B %d, %Y"),
    latest_transaction_date:   latest_transaction_date&.strftime("%B %d, %Y"),
    num_weeks:                 num_weeks,
    insured_amount:            insured_amount,
    current_balance:           current_balance,
    status:                    status,
    amt_past_due:              amt_past_due,
    num_weeks_past_due:        num_weeks_past_due,
    default_periodic_payment:  default_payment,
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
