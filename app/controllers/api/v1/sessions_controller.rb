class SessionsController < ApiController
  layout 'full'

  skip_before_filter :ensure_login, :only => [:new, :create]

  def create
    user = User.or({ :username => params[:login] }, { :email_address => params[:login] }).first || Account.where(email_address: params[:login]).first.try(:user)
    if user.try(:authenticate, params[:password])
      return render json: { user: user }
    end

    render json: { message: 'Invalid Login!' }
  end

  def destroy
    reset_session
    redirect_to login_url, notice:'Logged out!'
  end
end
