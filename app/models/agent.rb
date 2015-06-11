# == Schema Information
#
# Table name: agents
#
#  id         :integer          not null, primary key
#  name       :string
#  phone      :string
#  company_id :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Agent < ActiveRecord::Base
end
