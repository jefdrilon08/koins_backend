class ApplicationController < ActionController::API
  before_action :authorize_request

  attr_reader :current_user, :current_member

  private

  def authorize_request
    header = request.headers["Authorization"]
    return render json: { error: "Missing token" }, status: :unauthorized if header.blank?

    token = header.split(" ").last

    begin
      decoded = JsonWebToken.decode(token)
      return render json: { error: "Invalid token" }, status: :unauthorized if decoded.nil?

      # 👤 USER LOGIN
      if decoded[:user_id].present?
        @current_user = User.find(decoded[:user_id])

      # 👥 MEMBER LOGIN
      elsif decoded[:member_id].present?
        @current_member = Member.find(decoded[:member_id])

      else
        return render json: { error: "Invalid token payload" }, status: :unauthorized
      end

    rescue ActiveRecord::RecordNotFound
      render json: { error: "User or Member not found" }, status: :unauthorized

    rescue JWT::DecodeError
      render json: { error: "Token decode error" }, status: :unauthorized

    rescue JWT::ExpiredSignature
      render json: { error: "Token expired" }, status: :unauthorized
    end
  end
end
