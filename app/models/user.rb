class User < ApplicationRecord
    has_many :user_branches
  has_many :branches, through: :user_branches
end
