class ScheduledLocation < ApplicationRecord
  belongs_to :client, :foreign_key => 'client_id'
  belongs_to :business, :foreign_key => 'business_id'
  belongs_to :duration, :foreign_key => 'duration_id'
  belongs_to :extra_duration, :foreign_key => 'extra_duration_id'
end
