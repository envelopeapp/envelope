module Jobs
  class UserConfirmation < Struct.new(:user_id)
    def perform
      @user = User.find(user_id)
      return if @user.confirmed?

      @user.generate_token!(:confirmation_token)
      UserMailer.confirmation(@user).deliver!
    end

    def success
      @user.update_attributes!(confirmation_sent_at:Time.now)
    end
  end
end