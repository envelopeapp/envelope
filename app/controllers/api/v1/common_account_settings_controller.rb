module Api
  module V1
    class CommonAccountSettingsController < ApplicationController
      respond_to :json, :xml

      def index
        @common_account_settings = CommonAccountSetting.all
        respond_with @common_account_settings
      end
    end
  end
end
