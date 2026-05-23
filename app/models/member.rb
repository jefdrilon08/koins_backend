class Member < ApplicationRecord
  has_many :loans, foreign_key: "member_id"
  def hide_status
    data["hide_status"]
  end
end
