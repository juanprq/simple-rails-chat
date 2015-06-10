# == Schema Information
#
# Table name: organizations
#
#  id         :integer          not null, primary key
#  name       :string
#  token      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Organization < ActiveRecord::Base
  before_create :generate_token

  private

    def generate_token
      self.token = SecureRandom.base64(24)
    end
end
