class SessionsController < ApplicationController

	def create
		@user = User.find_by_name(params[:user][:name])
		if @user && @user.authenticate(params[:user][:password])
			session[:user_id] = @user.id

			# global broadcast: tell the world this user is online
			ActionCable.server.broadcast("room_channel_global",user_id: @user.id)

			redirect_to "/users/lobby"
		else
			flash[:error] = "Error signing in."
			redirect_to "/users/index"
		end

	end

	def destroy
		session[:user_id] = nil
		redirect_to "/users/index"
	end

	def broadcast_from_client
		# global broadcast: tell the world this user is online
		ActionCable.server.broadcast("room_channel_global",user_id: current_user.id)

		render json: nil
	end
end
