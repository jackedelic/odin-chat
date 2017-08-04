class RoomChannel < ApplicationCable::Channel
  def subscribed
  	if params.key? :group_id
	    stream_from "room_channel_#{params[:group_id]}"
	elsif params.key? :bot_human_id	
		stream_from "room_channel_bot_human_#{params[:bot_human_id]}"
	end
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def speak
  end
end
