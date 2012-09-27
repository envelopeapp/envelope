module Api
  module V1
    class ApiController < ::ActionController::API
      include Envelope::Auth

      before_filter :restrict_access!

      include CanCan::ControllerAdditions
      include ActionController::MimeResponds
      include ActionController::Helpers
      include ActionController::Cookies
      include ActionController::ImplicitRender

      private
      def restrict_access!
        head :unauthorized unless logged_in?
      end
    end
  end
end
