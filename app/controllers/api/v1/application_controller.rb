module Api
  module V1
    class ApplicationController < ::ActionController::API
      #before_filter :restrict_access!

      include CanCan::ControllerAdditions
      include ActionController::MimeResponds
      # include ActionController::Helpers
      # include ActionController::Cookies
      include ActionController::ImplicitRender

      private
      def current_user
        @current_user ||= User.first # User.find_by_access_key_and_secret_token(request.headers['HTTP_ACCESS_KEY'], request.headers['HTTP_SECRET_TOKEN'])
      end

      # def restrict_access!
      #   head :unauthorized unless current_user
      # end
    end
  end
end
