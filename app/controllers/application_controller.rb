# frozen_string_literal: true

class ApplicationController < ActionController::API
  private

  def render_bad_request(request)
    render json: { error: request.errors.full_messages.to_sentence }, status: :bad_request
  end
end
