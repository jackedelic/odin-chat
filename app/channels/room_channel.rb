class RoomChannel < ApplicationCable::Channel
  def subscribed
    stream_from "room_channel_#{params[:group_id]}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def speak
  end
end
