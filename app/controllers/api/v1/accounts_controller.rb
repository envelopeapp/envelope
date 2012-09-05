module Api
  module V1
    class AccountsController < ApplicationController
      respond_to :json

      def index
        respond_with(@accounts = current_user.accounts)
      end

      def show
        respond_with(@account = current_user.accounts.find(params[:id]))
      end

      def create
        respond_with(@account = current_user.accounts.create(params[:account]))
      end

      def update
        respond_with(@account = current_user.accounts.update(params[:id], params[:account]))
      end

      def destroy
        respond_with(current_user.accounts.destroy(params[:id]))
      end
    end
  end
end
