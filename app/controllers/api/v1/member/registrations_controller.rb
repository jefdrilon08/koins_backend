module Api
  module V1
    module Member
      class RegistrationsController < ApplicationController

        skip_before_action :authorize_request, only: [:create, :check_mobile, :check_duplicate]
        
        def check_mobile
          mobile = params[:mobile_number].to_s.strip
          exists = ::Member.where.not(mobile_number: ["", nil])
                   .exists?(mobile_number: mobile)
          render json: { exists: exists }
        end

        def check_duplicate
          first_name = params[:first_name].to_s.strip.downcase
          last_name  = params[:last_name].to_s.strip.downcase
          dob        = params[:date_of_birth].to_s.strip

          exists = ::Member.where(
            "LOWER(first_name) = ? AND LOWER(last_name) = ? AND date_of_birth = ?",
            first_name, last_name, dob
          ).exists?

          render json: { exists: exists }
        end

        def create

          default_data = {
            address: {
              street: "",
              district: nil,
              city: nil,
              province: nil,
              region: nil,
              old_district: nil,
              old_city: nil
            },

            spouse: {
              first_name: "",
              middle_name: "",
              last_name: "",
              date_of_birth: "",
              occupation: ""
            },

            government_identification_numbers: {
              sss_number: "",
              pag_ibig_number: "",
              phil_health_number: "",
              tin_number: ""
            },

            num_children_elementary: 0,
            num_children_high_school: 0,
            num_children_college: 0,
            num_children: 0,

            reason_for_joining: "",

            housing: {
              type: "",
              num_months: 0,
              num_years: 0,
              proof: ""
            },

            identity: {
              proof: ""
            },

            house: {
              proof: ""
            },

            banks: [],

            beneficiaries: [],

            project_types: [],

            hide_status: "pending",

            suffix: nil,

            is_qr: "true",

            qr_details: {
              qr_user_id: nil,
              qr_created_at: nil,
              for_check: nil,

              to_reject: {
                reason: nil,
                rejected_at: nil
              }
            },

            subscription: {
              is_subscribed: false,
              subscribe_created_at: nil,
              subscribe_updated_at: nil
            }
          }

          permitted = member_params.to_h

          permitted[:data] ||= {}

          permitted[:data] =
            default_data.deep_merge(
              permitted[:data].deep_symbolize_keys
            )

          member = ::Member.new(permitted)

          member.status = "for_check"

          member.insurance_status = "pending"

          if member.save

            render json: {
              success: true,
              message: "Registration submitted successfully.",
              member_id: member.id
            }

          else

            render json: {
              success: false,
              errors: member.errors.full_messages
            }, status: :unprocessable_entity

          end
        end

        private

        def member_params

          params.permit(
            :first_name,
            :middle_name,
            :last_name,
            :gender,
            :date_of_birth,
            :civil_status,
            :mobile_number,
            :home_number,
            :branch_id,
            :center_id,
            :member_type,
            :place_of_birth,
            :religion,
            :email,
            :membership_type_id,
            :membership_arrangement_id,

            data: [

              :num_children_elementary,
              :num_children_high_school,
              :num_children_college,
              :num_children,
              :reason_for_joining,
              :suffix,
              :is_qr,
              :hide_status,

              {
                address: [
                  :street,
                  :district,
                  :city,
                  :province,
                  :region,
                  :old_district,
                  :old_city
                ],

                spouse: [
                  :first_name,
                  :middle_name,
                  :last_name,
                  :date_of_birth,
                  :occupation
                ],

                government_identification_numbers: [
                  :sss_number,
                  :pag_ibig_number,
                  :phil_health_number,
                  :tin_number
                ],

                housing: [
                  :type,
                  :num_months,
                  :num_years,
                  :proof
                ],

                identity: [
                  :proof
                ],

                house: [
                  :proof
                ],

                banks: [
                  :name,
                  :account_type
                ],

                beneficiaries: [],

                project_types: [],

                qr_details: {},

                subscription: {}
              }
            ]
          )
        end
      end
    end
  end
end
