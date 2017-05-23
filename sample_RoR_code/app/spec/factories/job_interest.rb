# JobInterest Factory
FactoryGirl.define do
  factory :job_interest do
    id 1
    name 'Bubba Interested'
  end
end
# == Schema Information
#
# Table name: job_interests
#
#  id             :integer          not null, primary key
#  job_posting_id :integer
#  applicant_id   :integer
#  name           :string(255)
#  job_location   :string(255)
#  latitude       :float
#  longitude      :float
#  phone_number   :string(255)
#  email          :string(255)
#  why_me         :text
#  start_date     :datetime
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  status         :string(255)
#
