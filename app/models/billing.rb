class Billing < ApplicationRecord
  belongs_to :branch
  belongs_to :center, optional: true
# app/models/billing.rb
def decorated_data
  b_data = self.data.deep_symbolize_keys
  return b_data unless b_data[:records].present?

  # 1. Collect all member IDs from the JSON first
  member_ids = b_data[:records].map { |r| r.dig(:member, :id) }.compact.uniq

  # 2. Fetch all matching members in ONE single database query
  # This replaces the 225 separate SELECT statements
  members_map = Member.where(id: member_ids).index_by(&:id)

  # 3. Map through the records using the pre-fetched data
  b_data[:records].map! do |record|
    m_id = record.dig(:member, :id)
    member = members_map[m_id] # Look up in memory, not the database

    if member
      record[:member] = {
        id: member.id,
        full_name: "#{member.last_name}, #{member.first_name} #{member.middle_name}".strip.upcase,
        status: member.status,
        identification_number: member.identification_number
      }
      record[:member_name] = record[:member][:full_name]
    end
    record
  end
  b_data
end
end
