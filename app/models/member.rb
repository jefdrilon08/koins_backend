class Member < ApplicationRecord
  #has_secure_password :encrypted_password
  has_many :loans, foreign_key: "member_id"
  has_many :loan_applications
  has_many :beneficiaries, foreign_key: :member_id
  def hide_status
    data["hide_status"]
  end
end
