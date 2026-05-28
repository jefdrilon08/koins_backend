module Api
  module V1
    class CentersController < ApplicationController
      skip_before_action :authorize_request

      def index
        centers = Center
          .where(branch_id: params[:branch_id])
          .select(:id, :name)
          .order(:name)

        render json: {
          success: true,
          data: centers.map { |c|
            {
              id: c.id,
              name: c.name
            }
          }
        }
      end
    end
  end
end
