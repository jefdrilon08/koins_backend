module Api
  module V1
    class BranchesController < ApplicationController
      skip_before_action :authorize_request

      def index
        branches = Branch.order(:name)

        render json: {
          success: true,
          data: branches.map { |b|
            {
              id: b.id,
              name: b.name
            }
          }
        }
      end

      def centers
        centers = Center.where(branch_id: params[:id]) # 👈 safer with Rails member route

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
