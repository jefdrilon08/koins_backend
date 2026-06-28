module Api
  module V1
    module Member
      class BeneficiariesController < ApplicationController
        skip_before_action :authorize_request, only: [:create]
        before_action :authorize_request, only: [:index]  # 👈 protect index with token

        def index
          # Using @current_member directly ensures they only see their own data
          #beneficiaries = @current_member.beneficiaries
          #                               .where(is_deceased: false)
          #                               .order(is_primary: :desc, first_name: :asc)
          beneficiaries = @current_member.beneficiaries
                                          .where(is_deceased: [false, nil])
                                          .order(is_primary: :desc, first_name: :asc)
          render json: {
            success: true,
            data: beneficiaries.map { |b|
              {
                id:            b.id,
                first_name:    b.first_name,
                middle_name:   b.middle_name,
                last_name:     b.last_name,
                relationship:  b.relationship,
                date_of_birth: b.date_of_birth&.strftime("%Y-%m-%d"),
                is_primary:    b.is_primary,
                is_deceased:   b.is_deceased,
              }
            }
          }, status: :ok
        end

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
