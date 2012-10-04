class UserMailer < ActionMailer::Base
  def confirmation(user_id)
    @user = User.find(user_id)
    mail(to:@user.email_address, subject:'Welcome to Envelope!', from:'teamenvelope@gmail.com')
  end

  def reset_password(user_id)
    @user = User.find(user_id)
    mail(to:@user.email_address, subject:'Envelope Password Reset', from:'teamenvelope@gmail.com')
  end
end
