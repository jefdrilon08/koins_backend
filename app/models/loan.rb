class Loan < ApplicationRecord
  belongs_to :loan_product
   has_many :amortization_schedule_entries, foreign_key: :loan_id
end
