require 'net/http'
require 'uri'
require 'open-uri'
require 'rest-client'
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

	def bot_reply
		# tell the world the user is online
		ActionCable.server.broadcast("room_channel_global",user_id: current_user.id)

		@message_content = params[:message]


		# broadcast bot's message to the user
		bot_replies = generate_bot_message(@message_content)
		bot_replies.each do |bot_reply|
			ActionCable.server.broadcast("room_channel_bot_human_#{current_user.id}",content: bot_reply)
		end

		render json: bot_replies

	end

	def generate_bot_message(user_message)
		user_message = user_message.downcase.chomp.strip
		human_questions = JSON.parse(File.open("lib/assets/human_questions.rb","r").read)
		bot_answers = JSON.parse(File.open("lib/assets/bot_answers.rb","r").read)

		answers = []
		human_questions.each do |kind,qn_array|
			qn_array.each do |qn|
				if user_message =~ /#{qn}/
					answers << bot_answers[kind][rand(0...bot_answers[kind].length)]

				end
			end
		end
		if answers.empty?
			# if bot doesn't understand the human question
			answers << bot_answers["non-interpretable"][rand(0...bot_answers["non-interpretable"].length)]
			return answers
		elsif answers[0] == "what is"
			answers = []
			answers << analyse_user_message(user_message,answers)
			return answers
		else
			return answers
		end

	end

	def request_word_meaning(word)
		resp = []
		res = RestClient.get('https://owlbot.info/api/v1/dictionary/'+word+'?format=json')
		JSON.parse(res).each do |item|
			resp << item['defenition']
		end
		return resp
	end

	def analyse_user_message(user_message,answers)
		#after splitting => ["","...."]
		word = ""
		if user_message.split("what is a").length == 2
			word = user_message.split("what is a")[1].match(/[a-z]+/)[0]
		elsif user_message.split("what is").length == 2
			# doing math
			crucial_part =  user_message.split("what is")[1]
			if crucial_part =~ /[0-9]/
				return evaluate_math(crucial_part)
			else
				word = user_message.split("what is")[1].match(/[a-z]+/)[0]
			end

		elsif user_message.split("what does").length == 2
			word = user_message.split("what does")[1].match(/[a-z]+/)[0]
		elsif user_message.split("define").length == 2
			word = user_message.split("define")[1].match(/[a-z]+/)[0]
		else
			word = user_message.split("what")[1].match(/[a-z]+/)[0]
		end
		# handle undefined
		if request_word_meaning(word).empty?
			answers << "is it a typo?"
			return answers
		else #use dictionary
			request_word_meaning(word).each_with_index do |item,i|
				answers << ((i+1).to_s + ". " + item)
			end
			return answers
		end
	end

	def evaluate_math(expr)
		expr = expr.match(/[^\?]+/)[0]
		# turn "math" to "Math"
		expr = expr.gsub('math','Math')
		# function without Math prepended
		expr = expr.gsub(/(asinh|acosh|atanh|asin|acos|atan|sin|cos|tan|log)/,'Math::\1')
		return eval(expr)
	end
end
