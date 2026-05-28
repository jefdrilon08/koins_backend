module Api
  module V1
    module Member
      class BeneficiariesController < ApplicationController
        skip_before_action :authorize_request

        def create
          member = ::Member.find_by(id: params[:beneficiary][:member_id])

          return render json: { success: false, error: "Member not found" }, status: :not_found if member.nil?

          beneficiary = member.beneficiaries.new(beneficiary_params)

          if beneficiary.save
            render json: { success: true, data: beneficiary }, status: :created
          else
            render json: { success: false, errors: beneficiary.errors.full_messages }, status: :unprocessable_entity
          end
        end

        private

        def beneficiary_params
          params.require(:beneficiary).permit(
            :member_id,
            :first_name,
            :middle_name,
            :last_name,
            :relationship,
            :date_of_birth,
            :is_primary,
            :is_deceased
          )
        end
      end
    end
  end
end
