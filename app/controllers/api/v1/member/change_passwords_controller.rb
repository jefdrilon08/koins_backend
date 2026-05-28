module Api
  module V1
    module Member
      class ChangePasswordsController < ApplicationController
        before_action :authorize_request

        def update
          old_password     = params[:old_password]
          new_password     = params[:new_password]
          confirm_password = params[:confirm_password]

          # REQUIRED
          if old_password.blank? || new_password.blank?
            return render json: {
              success: false,
              message: "Old password and new password are required."
            }, status: :unprocessable_entity
          end

          # VERIFY CURRENT PASSWORD
          unless BCrypt::Password.new(
            @current_member.encrypted_password
          ) == old_password

            return render json: {
              success: false,
              message: "Current password is incorrect."
            }, status: :unprocessable_entity
          end

          # MUST DIFFER
          if old_password == new_password
            return render json: {
              success: false,
              message: "New password must be different from your current password."
            }, status: :unprocessable_entity
          end

          # MIN LENGTH
          if new_password.length < 8
            return render json: {
              success: false,
              message: "New password must be at least 8 characters."
            }, status: :unprocessable_entity
          end

          # CONFIRM MATCH
          if confirm_password.present? &&
             new_password != confirm_password

            return render json: {
              success: false,
              message: "Passwords do not match."
            }, status: :unprocessable_entity
          end

          # UPDATE PASSWORD
          encrypted =
            BCrypt::Password.create(
              new_password
            )

          if @current_member.update(
            encrypted_password: encrypted
          )

            render json: {
              success: true,
              message: "Password changed successfully."
            }, status: :ok

          else

            render json: {
              success: false,
              message: @current_member
                .errors
                .full_messages
                .join(", ")
            }, status: :unprocessable_entity

          end
        end
      end
    end
  end
end
