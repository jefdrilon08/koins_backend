module Api
  module V1
    class BillingsController < ApplicationController
      before_action :authorize_request

      # GET /api/v1/billings
      def index
        active_branch_ids = @current_user.branches
                                          .where(user_branches: { active: true })
                                          .pluck(:id)

        @billings =
          if active_branch_ids.any?
            Billing.includes(:branch, :center)
                   .where(branch_id: active_branch_ids, status: 'pending')
                   .order(collection_date: :desc)
          else
            Billing.none
          end

render json: @billings.map { |b|
  {
    id: b.id,
    collection_date: b.collection_date,
    status: b.status,
    total_collected: b.total_collected,
    total_expected_collections: b.total_expected_collections,
    or_number: b.or_number,
    ar_number: b.ar_number,
    si_number: b.si_number,
    branch: { id: b.branch&.id, name: b.branch&.name },
    center: { id: b.center&.id, name: b.center&.name },

    records: b.data&.dig("records")&.map do |r|
      {
        member: {
          id: r.dig("member", "id"),
          name: r.dig("member", "name"),
          hide_status: Member.find_by(id: r.dig("member", "id"))&.data&.dig("hide_status") || "inactive"
        }
      }
    end
  }
}
      end

      # GET /api/v1/billings/:id
def show
  billing = Billing.includes(:branch, :center).find(params[:id])

  data    = billing.data || {}
  headers = data["headers"] || []
  records = data["records"] || []

  member_ids = records.map { |r| r.dig("member", "id") }.compact
  members    = Member.where(id: member_ids).index_by(&:id)

  render json: {
    id:                         billing.id,
    collection_date:            billing.collection_date,
    status:                     billing.status,
    total_collected:            billing.total_collected,
    total_expected_collections: billing.total_expected_collections,
    or_number:                  billing.or_number,
    ar_number:                  billing.ar_number,
    si_number:                  billing.si_number,
    branch:                     { id: billing.branch&.id, name: billing.branch&.name },
    center:                     { id: billing.center&.id, name: billing.center&.name },
    headers:                    headers,
     data:                       data,  # ← add full data including accounting_entry
    records:                    records.map { |r|
      member_id   = r.dig("member", "id")
      member      = members[member_id]
      sub_records = r["records"] || []

      columns = headers.each_with_object({}) do |header, hash|
        match = sub_records.find do |sr|
          loan_name   = sr.dig("loan_product", "name")
          subtype     = sr["account_subtype"]
          record_type = sr["record_type"]
          case record_type
          when "LOAN_PAYMENT" then header == loan_name
          when "SAVINGS"      then header == "Deposit #{subtype}"
          when "EQUITY"       then header == "Deposit #{subtype}"
          when "INSURANCE"    then header == "Insurance #{subtype}"
          when "WP"           then header == "WP"
          else false
          end
        end
        hash[header] = match ? match["amount"].to_f : 0.0
      end

      {
        member: {
          id:   member_id,
          name: member ? "#{member.last_name}, #{member.first_name}" : r.dig("member", "full_name")
        },
        columns:                    columns,
        total_collected:            r["total_collected"].to_f,
        total_expected_collections: r["total_expected_collections"].to_f,
        raw_records:                sub_records  # ← this line adds raw_records
      }
    }
  }
end
      # POST /api/v1/billings/sync
def sync
  synced = []
  failed = []
  billing_params_list = params[:billings] || []

  billing_params_list.each do |bp|
    begin
      bp = bp.to_unsafe_h if bp.respond_to?(:to_unsafe_h)  # ← add this

      billing = Billing.find_or_initialize_by(id: bp["id"])

      existing_data    = billing.data || {}
      existing_records = existing_data["records"] || []

      existing_member_data = existing_records.each_with_object({}) do |r, h|
        mid = r.dig("member", "id")
        h[mid] = r["member"] if mid
      end

incoming_records = (bp["records"] || []).map do |r|
  r = r.to_unsafe_h if r.respond_to?(:to_unsafe_h)
  member_id       = r.dig("member", "id") || r["member_id"]
  existing_member = existing_member_data[member_id] || {}

  # find existing record for this member to preserve nested records[]
  existing_record = existing_records.find { |er| er.dig("member", "id") == member_id } || {}

  merged_member = existing_member.merge(r["member"] || {})

  # preserve nested records[] from existing — old Rails app needs this
  r.merge(
    "member"  => merged_member,
    "records" => r["records"].presence || existing_record["records"] || []
  )
end
      final_records = incoming_records.presence || existing_records

      headers          = bp["headers"] || existing_data["headers"] || []
      accounting_entry = bp["accounting_entry"] || {}
      accounting_entry = accounting_entry.to_unsafe_h if accounting_entry.respond_to?(:to_unsafe_h)

      journal_entries        = accounting_entry["journal_entries"]        || []
      credit_journal_entries = accounting_entry["credit_journal_entries"] || []
      debit_journal_entries  = accounting_entry["debit_journal_entries"]  || []

      merged_data = existing_data.deep_dup
      merged_data["headers"] = headers.presence || existing_data["headers"] || []
      merged_data["records"] = final_records
      merged_data["totals"]  = bp["totals"] || existing_data["totals"] || []
      merged_data["accounting_entry"] = (existing_data["accounting_entry"] || {}).merge(
        accounting_entry.merge(
          "journal_entries"        => journal_entries,
          "credit_journal_entries" => credit_journal_entries,
          "debit_journal_entries"  => debit_journal_entries
        )
      )

      billing.assign_attributes(
        collection_date:            bp["collection_date"],
        center_id:                  bp.dig("center", "id"),
        branch_id:                  bp.dig("branch", "id"),
        data:                       merged_data,
        status:                     bp["status"] || billing.status || "pending",
        total_collected:            bp["total_collected"].to_f,
        total_expected_collections: bp["total_expected_collections"].to_f,
        or_number:                  bp["or_number"],
        ar_number:                  bp["ar_number"],
        si_number:                  bp["si_number"]
      )

      if billing.save
        synced << { id: billing.id, status: billing.status }
      else
        failed << { id: bp["id"], errors: billing.errors.full_messages }
      end
    rescue => e
      Rails.logger.error("SYNC ERROR: #{e.message}")
      Rails.logger.error(e.backtrace.join("\n"))
      failed << { id: bp["id"], errors: [e.message] }
    end
  end

  render json: { synced: synced, failed: failed }, status: :ok
end
end
  end
end
