class UserBranch < ApplicationRecord
  belongs_to :user
  belongs_to :branch
end
