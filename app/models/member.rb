class Member < ApplicationRecord
  def hide_status
    data["hide_status"]
  end
end
