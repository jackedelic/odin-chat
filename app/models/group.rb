class Group < ApplicationRecord
	has_many :group_users, class_name: 'GroupUser'
	has_many :users, through: :group_users
	has_many :messages
end
