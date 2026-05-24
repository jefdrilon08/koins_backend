module Api
  module V1
    class ProjectTypesController < ApplicationController

      # GET /api/v1/project_type_categories
      def categories

        categories =
          ProjectTypeCategory
            .where(is_active: true)
            .order(:name)

        render json: categories.map { |c|
          {
            id: c.id,
            name: c.name,
            code: c.code
          }
        }

      end

      # GET /api/v1/project_types
      # optional:
      # ?project_type_category_id=UUID
      def index

        project_types =
          ProjectType
            .where(is_active: true)

        if params[:project_type_category_id].present?

          project_types =
            project_types.where(
              project_type_category_id:
                params[:project_type_category_id]
            )

        end

        project_types =
          project_types.order(:name)

        render json: project_types.map { |p|
          {
            id: p.id,
            name: p.name,
            code: p.code,
            project_type_category_id:
              p.project_type_category_id
          }
        }

      end

    end
  end
end
