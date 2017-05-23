# JobRegistration Factory
FactoryGirl.define do
  factory :job_registration do
    id 1
    account_id 1
    job_fee_id 1
    job_posting_id 1
    start_date Time.zone.now
  end
end
# == Schema Information
#
# Table name: job_registrations
#
#  id             :integer          not null, primary key
#  account_id     :integer
#  job_posting_id :integer
#  job_fee_id     :integer
#  start_date     :datetime
#  end_date       :datetime
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

