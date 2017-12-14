class Business < ApplicationRecord
  has_many :users, through: :user_businesses
  has_many :user_businesses

  belongs_to :user

  accepts_nested_attributes_for :user_businesses

  # accepts_nested_attributes_for :users
  # accepts_nested_attributes_for :users, allow_destroy: true
end
