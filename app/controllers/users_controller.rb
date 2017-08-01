class UsersController < ApplicationController
	before_action :authorize, only: [:lobby]

	def index
		
	end

	def lobby
		@users = User.all.reject{|u| u.id == current_user.id}
		@user = current_user
		# global broadcast: tell the world this user is online
		ActionCable.server.broadcast("room_channel_global",user_id: @user.id)
	end

	def create
		@user = User.new(name: params[:user][:name], password: params[:user][:password], password_confirmation: params[:user][:password_confirmation])
		begin	
			if @user.save
				session[:user_id] = @user.id
				redirect_to '/users/lobby'
			else	
				flash[:error] = @user.errors.full_messages[0]
				redirect_to '/users/index'
			end
		rescue
			flash[:error] = "I am sorry. Username exists in the database. I guess \"#{@user.name}\" isn't that unique afterall"
			redirect_to '/users/index'

		end
	end
end
