# == Schema Information
#
# Table name: companies
#
#  id         :integer          not null, primary key
#  name       :string
#  token      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Company < ActiveRecord::Base
  before_create :generate_token
  has_many :agents

  private
    def generate_token
      self.token = SecureRandom.base64(24)
    end
end
