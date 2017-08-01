class MessagesController < ApplicationController
	def all_messages_in_particular_group
		# tell the world the user is online
		ActionCable.server.broadcast("room_channel_global",user_id: current_user.id)

		@partner_id = params[:partner_id].to_i
		@partner = User.find_by_id(@partner_id)
		# create new group if such group does not exist previously, else just use the existing group
		Group.all.each do |group|
		
			if (!group.users.empty?) && (group.users.first.id == @partner_id && group.users.last.id == current_user.id) || (group.users.first.id == current_user.id && group.users.last.id == @partner_id)
				# use the existing group
				@group = group
			end
			
		end
		unless @group
			# create new group
			@group = Group.new
			@group.save
			@group.users << @partner << current_user
		end

		@messages = @group.messages
		if @messages.empty?
			render json: @group
		else
			render json: @messages
		end
	end

	def create
		# tell the world the user is online
		ActionCable.server.broadcast("room_channel_global",user_id: current_user.id)

		# create new message
		@message = Message.new(content: params[:message])

		# find the partner
		@partner_id = params[:partner_id].to_i
		@partner = User.find_by_id(@partner_id.to_i)

		# find the group
		Group.all.each do |group|
			if (group.users.first.id == @partner_id && group.users.last.id == current_user.id) || (group.users.first.id == current_user.id && group.users.last.id == @partner_id)
				# use the existing group
				@group = group
			end
		end
		# associate message with the group
		@group.messages << @message

		if current_user.messages << @message 
			ActionCable.server.broadcast("room_channel_#{@group.id}",content: @message.content, user_id: current_user.id)
		end

		render json: @group.messages
	end

	def destroy

	end
end
