class PusherController < ApplicationController
  protect_from_forgery :except => :auth

  def auth
    if current_user && current_user.id.to_s == params[:channel_name].gsub('private-', '')
      response = Pusher[params[:channel_name]].authenticate(params[:socket_id])
      render json: response
    else
      render text: 'Could not authenticate to pusher', status: '403'
    end
  end
end
