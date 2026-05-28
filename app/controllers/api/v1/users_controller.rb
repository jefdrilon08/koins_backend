class Api::V1::UsersController < ApplicationController
  skip_before_action :authorize_request
  def branches_centers

    user = User.find(params[:user_id])

    centers = Center.where(user_id: user.id)

    branch_ids =
      centers.pluck(:branch_id).uniq

    branches =
      Branch.where(id: branch_ids)

    render json: {
      success: true,
      branches: branches.as_json(
        only: [:id, :name]
      ),
      centers: centers.as_json(
        only: [
          :id,
          :name,
          :branch_id,
          :user_id
        ]
      )
    }

  end

end
