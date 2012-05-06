module Jobs
  class UserResetPassword < Struct.new(:user_id)
    def perform
      @user = User.find(user_id)

      @user.generate_token!(:reset_password_token)
      UserMailer.reset_password(@user).deliver!
    end

    def success
      @user.update_attributes!(reset_password_sent_at:Time.now)
    end
  end
end