module Api
  module V1
    module Member
      class CoMakersController < ApplicationController
        before_action :authorize_request

        def index

          members =
            ::Member
              .where(
                center_id: @current_member.center_id,
                status: "active"
              )
              .where.not(
                id: @current_member.id
              )

          render json: members.map { |m|
            {
              id: m.id,
              name: "#{m.first_name} #{m.last_name}"
            }
          }
        end
      end
    end
  end
end
