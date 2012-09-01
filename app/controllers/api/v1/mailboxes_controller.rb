module Api
  module V1
    class MailboxesController < ApplicationController
      load_and_authorize_resource :account, :through => :current_user
      load_and_authorize_resource :mailbox, :through => :account

      respond_to :json, :xml

      def index
        respond_with(@mailboxes)
      end

      def show
        respond_with(@mailbox)
      end
    end
  end
end
