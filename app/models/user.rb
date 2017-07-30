class User < ApplicationRecord
	has_secure_password
	has_many :messages
	belongs_to :chatroom, optional: true
	has_many :group_users, class_name: "GroupUser"
	has_many :groups, through: :group_users
end
