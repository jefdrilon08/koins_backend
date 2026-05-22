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
              branches: user.branches.where(user_branches: { active: true }).map do |b|
                {
                  id: b.id,
                  name: b.name
                  #centers: b.centers.map do |c|
                  #  {
                  #    id: c.id,
                  #    name: c.name,
                  #    short_name: c.short_name,
                  #    meeting_day: c.meeting_day,
                  #    lat: c.lat,
                  #    lon: c.lon
                  #  }
                  #end
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
