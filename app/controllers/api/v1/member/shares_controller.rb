module Api
  module V1
    module Member
      class SharesController < ApplicationController
        before_action :authorize_request

        def index
          shares =
            ::MemberShare
              .where(member_id: @current_member.id)
              .order(created_at: :desc)

          render json: shares.map { |s|
            {
              id: s.id,
              certificate_number: s.certificate_number,
              number_of_shares: s.number_of_shares,
              certificate_for: s.certificate_for,
              date_of_issue: s.date_of_issue,
              created_at: s.created_at
            }
          }
        end
      end
    end
  end
end
