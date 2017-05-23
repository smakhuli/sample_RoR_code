job_interest.rb# JobFee Factory
FactoryGirl.define do
  factory :job_fee_1, :class => :job_fee do
    id 1
    number_of_months 1
    fee 100.to_money
  end
end
FactoryGirl.define do
  factory :job_fee_2, :class => :job_fee  do
    id 1
    number_of_months 2
    fee 200.to_money
  end
end
# == Schema Information
#
# Table name: job_fees
#
#  id               :integer          not null, primary key
#  number_of_months :integer
#  fee              :decimal(10, 2)   default(0.0)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
