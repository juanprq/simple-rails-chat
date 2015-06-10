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

  def self.open_by_organization_token(token)
    includes(:organization)
    .references(:organization)
    .where(status: 'open', organizations: {token: token})
    .order(:created_at)
  end

end
