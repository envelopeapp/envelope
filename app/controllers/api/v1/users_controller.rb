module Api
  module V1
    class UsersController < ApplicationController
      respond_to :json, :xml

      def index
        @users = User.all
        respond_with(@users)
      end

      def show
        @user = User.first
        respond_with(@user)
      end
    end
  end
end
