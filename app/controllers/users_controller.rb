class UsersController < ApplicationController
	before_action :authorize, only: [:lobby]

	def index
		
	end

	def lobby
		@users = User.all
		@user = current_user
	end

	def create
		@user = User.new(name: params[:user][:name], password: params[:user][:password], password_confirmation: params[:user][:password_confirmation])
		if @user.save
			session[:user_id] = @user.id
			redirect_to '/users/lobby'
		else	
			redirect_to '/users/index'
		end
	end
end
