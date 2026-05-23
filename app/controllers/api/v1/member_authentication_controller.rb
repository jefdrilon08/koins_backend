module Api
  module V1
    class MemberAuthenticationController < ApplicationController
      skip_before_action :authorize_request, only: [:login]

      def login
        member = ::Member.find_by(username: params[:username])

        if member && valid_password?(member, params[:password])
          token = JsonWebToken.encode(member_id: member.id)

          render json: {
            token: token,
            member: {
              id: member.id,
              username: member.username,
              first_name: member.first_name,
              last_name: member.last_name,
              branch_id: member.branch_id,
              center_id: member.center_id,
              status: member.status
            }
          }
        else
          render json: { error: "Invalid username or password" }, status: :unauthorized
        end
      end

      private

      def valid_password?(member, password)
        BCrypt::Password.new(member.encrypted_password) == password
      rescue
        false
      end
    end
  end
end
