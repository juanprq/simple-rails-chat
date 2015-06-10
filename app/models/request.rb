# == Schema Information
#
# Table name: requests
#
#  id              :integer          not null, primary key
#  name            :string
#  status          :string
#  token           :string
#  organization_id :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class Request < ActiveRecord::Base

  belongs_to :organization

end
