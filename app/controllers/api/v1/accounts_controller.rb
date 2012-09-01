module Api
  module V1
    class AccountsController < ApplicationController
      respond_to :json, :xml

      def index
        @accounts = current_user.accounts
        respond_with(@accounts)
      end

      def show
        @account = current_user.accounts.find(params[:id])
        respond_with(@account)
      end
    end
  end
end
