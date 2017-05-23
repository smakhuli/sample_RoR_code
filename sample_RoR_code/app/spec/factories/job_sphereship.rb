# JobSphereship Factory
FactoryGirl.define do
  factory :job_sphereship do
    id 1
  end
end
# == Schema Information
#
# Table name: job_sphereships
#
#  id             :integer          not null, primary key
#  job_posting_id :integer
#  job_sphere_id  :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
