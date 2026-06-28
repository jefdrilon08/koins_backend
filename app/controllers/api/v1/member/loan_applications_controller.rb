module Api
  module V1
    module Member
      class LoanApplicationsController < ApplicationController
        before_action :authorize_request

        # =====================================
        # GET MEMBER LOAN APPLICATIONS
        # =====================================
        def index

          loans = ::LoanApplication
            .where(
              member_id: @current_member.id
            )
            .order(created_at: :desc)

          render json: loans.map { |loan|

            {
              id: loan.id,
              reference_number:
                loan.reference_number,

              loan_product_id:
                loan.loan_product_id,

              amount:
                loan.amount,

              term:
                loan.term,

              num_installments:
                loan.num_installments,

              status:
                loan.status,

              date_applied:
                loan.date_applied,

              date_approved:
                loan.date_approved,

              co_maker_member_id:
                loan.co_maker_member_id,

              co_maker_first_name:
                loan.co_maker_first_name,

              co_maker_last_name:
                loan.co_maker_last_name,

              data:
                loan.data,

              created_at:
                loan.created_at
            }

          }
        end

        # =====================================
        # CREATE LOAN APPLICATION
        # =====================================
        def create

          loan = ::LoanApplication.new(

            member_id:
              @current_member.id,

            loan_product_id:
              params[:loan_product_id],

            amount:
              params[:amount],

            term:
              params[:term],

            num_installments:
              params[:num_installments],

            status:
              "pending",

            date_applied:
              Date.today,

            reference_number:
              SecureRandom.hex(3).upcase,

            co_maker_member_id:
              params[:co_maker_member_id],

            co_maker_first_name:
              params[:co_maker_first_name],

            co_maker_last_name:
              params[:co_maker_last_name],

            # =================================
            # JSON DATA FIELD
            # =================================
            data: {

              # -----------------------------
              # SO FILE
              # -----------------------------
              so_file: {

                sit_down:
                  params.dig(
                    :so_file,
                    :sit_down
                  ),

                bilang_ng_absent:
                  params.dig(
                    :so_file,
                    :bilang_ng_absent
                  ) || 0,

                palya_sa_pagiimpok:
                  params.dig(
                    :so_file,
                    :palya_sa_pagiimpok
                  ) || 0,

                kasalukuyang_insurance:
                  params.dig(
                    :so_file,
                    :kasalukuyang_insurance
                  ),

                tungkulin_bilang_co_maker:
                  params.dig(
                    :so_file,
                    :tungkulin_bilang_co_maker
                  )
              },

              # -----------------------------
              # CASH FLOW
              # -----------------------------
              cash_flow: {

                iba_pa:
                  params.dig(
                    :cash_flow,
                    :iba_pa
                  ) || 0,

                gastos_sa_baon:
                  params.dig(
                    :cash_flow,
                    :gastos_sa_baon
                  ) || 0,

                gastos_sa_gamot:
                  params.dig(
                    :cash_flow,
                    :gastos_sa_gamot
                  ) || 0,

                hulugan_sa_coop:
                  params.dig(
                    :cash_flow,
                    :hulugan_sa_coop
                  ) || 0,

                kita_sa_negosyo:
                  params.dig(
                    :cash_flow,
                    :kita_sa_negosyo
                  ) || 0,

                bayarin_sa_tubig:
                  params.dig(
                    :cash_flow,
                    :bayarin_sa_tubig
                  ) || 0,

                gastos_sa_negosyo:
                  params.dig(
                    :cash_flow,
                    :gastos_sa_negosyo
                  ) || 0,

                gastos_sa_pagkain:
                  params.dig(
                    :cash_flow,
                    :gastos_sa_pagkain
                  ) || 0,

                kita_mula_sa_asawa:
                  params.dig(
                    :cash_flow,
                    :kita_mula_sa_asawa
                  ) || 0,

                kita_mula_sa_kasama:
                  params.dig(
                    :cash_flow,
                    :kita_mula_sa_kasama
                  ) || 0,

                hulugan_bukod_sa_coop:
                  params.dig(
                    :cash_flow,
                    :hulugan_bukod_sa_coop
                  ) || 0,

                iba_pang_pinagkakakitaan:
                  params.dig(
                    :cash_flow,
                    :iba_pang_pinagkakakitaan
                  ) || 0
              },

              # -----------------------------
              # OTHER DATA
              # -----------------------------
              mobile_number:
                params[:mobile_number],

              project_type_id:
                params[:project_type_id],

              # -----------------------------
              # BENEFICIARY
              # -----------------------------
              clip_beneficiary: {

                first_name:
                  params.dig(
                    :clip_beneficiary,
                    :first_name
                  ),

                middle_name:
                  params.dig(
                    :clip_beneficiary,
                    :middle_name
                  ),

                last_name:
                  params.dig(
                    :clip_beneficiary,
                    :last_name
                  ),

                relationship:
                  params.dig(
                    :clip_beneficiary,
                    :relationship
                  ),

                date_of_birth:
                  params.dig(
                    :clip_beneficiary,
                    :date_of_birth
                  )
              }
            }
          )

          # =====================================
          # SAVE
          # =====================================
          if loan.save

            render json: {
              success: true,
              message:
                "Loan application submitted successfully",
              loan_id:
                loan.id,
              reference_number:
                loan.reference_number
            }, status: :created

          else

            render json: {
              success: false,
              errors:
                loan.errors.full_messages
            }, status: :unprocessable_entity

          end
        end

        # GET /api/v1/member/loan_applications/last
def last
  last_loan = current_member
                .loans
                .order(created_at: :desc)
                .first
  return render json: { found: false } if last_loan.nil?

  pt  = ProjectType.find_by(id: last_loan.project_type_id)
  ptc = pt ? ProjectTypeCategory.find_by(id: pt.project_type_category_id) : nil

  loan_data     = last_loan.data || {}
  co_maker_one  = loan_data["co_maker_one"] || {}

  co_maker_two       = loan_data["co_maker_two"].to_s.strip
  co_maker_two_parts = co_maker_two.split(" ")
  co_maker_two_first = co_maker_two_parts[0] || ""
  co_maker_two_last  = co_maker_two_parts[1..].join(" ")

  # ── Co-maker active check ──────────────────────────────────────────────────
  #co_maker_member = Member.find_by(id: co_maker_one["id"])
  co_maker_member = ::Member.find_by(id: co_maker_one["id"])
  co_maker_active = co_maker_member&.status == "active"   # adjust value to match your DB

  co_maker_payload = if co_maker_active
    {
      member_id:  co_maker_one["id"].presence,
      first_name: co_maker_one["first_name"].to_s,
      last_name:  co_maker_one["last_name"].to_s
    }
  else
    { member_id: nil, first_name: nil, last_name: nil }
  end
  # ──────────────────────────────────────────────────────────────────────────

  render json: {
    found: true,
    project_type_category: ptc ? { id: ptc.id.to_s, name: ptc.name, code: ptc.code } : nil,
    project_type:          pt  ? { id: pt.id.to_s,  name: pt.name,  code: pt.code,
                                   project_type_category_id: pt.project_type_category_id.to_s } : nil,
    co_maker:          co_maker_payload,
    co_maker_sa_bahay: { first_name: co_maker_two_first, last_name: co_maker_two_last },
    mobile_number:     current_member.mobile_number
  }
end
      end
    end
  end
end
