module Api
  module V1
    module Addresses
      class AddressesController < ApplicationController
        skip_before_action :authorize_request  # ← add this line

        # GET /api/v1/addresses/regions
        def regions
          regions = AdminAddress
            .select(:id, :region_name)
            .order(:region_name)

          render json: {
            success: true,
            data: regions.map { |r|
              {
                id: r.id,
                name: r.region_name
              }
            }
          }
        end

        # GET /api/v1/addresses/provinces?region_id=UUID
        def provinces
          provinces = AdminProvince
            .where(region_id: params[:region_id])
            .select(:id, :province_name)
            .order(:province_name)

          render json: {
            success: true,
            data: provinces.map { |p|
              {
                id: p.id,
                name: p.province_name
              }
            }
          }
        end

        # GET /api/v1/addresses/municipalities?province_id=UUID
        def municipalities
          municipalities = AdminMunicipality
            .where(province_id: params[:province_id])
            .select(:id, :municipality_name)
            .order(:municipality_name)

          render json: {
            success: true,
            data: municipalities.map { |m|
              {
                id: m.id,
                name: m.municipality_name
              }
            }
          }
        end

        # GET /api/v1/addresses/barangays?municipality_id=UUID
        def barangays
          barangays = AdminBarangay
            .where(municipality_id: params[:municipality_id])
            .select(:id, :barangay_name)
            .order(:barangay_name)

          render json: {
            success: true,
            data: barangays.map { |b|
              {
                id: b.id,
                name: b.barangay_name
              }
            }
          }
        end

      end
    end
  end
end
