class SessionsController < ApplicationController

	def create
		@user = User.find_by_name(params[:user][:name])
		if @user && @user.authenticate(params[:user][:password])
			session[:user_id] = @user.id
			redirect_to "/users/lobby"
		else
			redirect_to "/users/index"
		end

	end

	def destroy
		session[:user_id] = nil
		redirect_to "/users/index"
	end
end
