module Api
  module V1
    class AuthenticationController < ApplicationController
      skip_before_action :authorize_request, only: [:login]

      def login
        user = User.find_by(username: params[:username])

        if user && BCrypt::Password.new(user.encrypted_password) == params[:password]
          token = JsonWebToken.encode(user_id: user.id)

          render json: {
            token: token,
            user: {
              id: user.id,
              username: user.username,
              email: user.email,
              insurance_status: user.insurance_status,
              branches: user.branches.where(user_branches: { active: true }).map do |b|
                {
                  id: b.id,
                  name: b.name
                }
              end
            }
          }
        else
          render json: { error: 'Invalid username or password' }, status: :unauthorized
        end
      end
    end
  end
end
