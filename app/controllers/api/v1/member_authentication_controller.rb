module Api
  module V1
    class MemberAuthenticationController < ApplicationController
      skip_before_action :authorize_request, only: [:login]

      def login
        member = ::Member.find_by(username: params[:username])

        if member && valid_password?(member, params[:password])

          token = JsonWebToken.encode(member_id: member.id)

          branch = Branch.find_by(id: member.branch_id)
          center = Center.find_by(id: member.center_id)

          membership_payment = MembershipPaymentRecord.where(
            member_id: member.id,
            status: "paid",
            membership_name: "K-KOOP",
            date_voided: nil
          ).order(date_paid: :asc).first

          render json: {
            token: token,
            member: {
              id: member.id,
              username: member.username,
              first_name: member.first_name,
              last_name: member.last_name,
              branch_id: member.branch_id,
              branch_name: branch&.name,
              center_id: member.center_id,
              center_name: center&.name,
              status: member.status,
              identification_number: member.identification_number,
              date_of_membership: membership_payment&.date_paid,
              member_type: member.member_type,
            }
          }

        else
          render json: {
            error: "Invalid username or password"
          }, status: :unauthorized
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
