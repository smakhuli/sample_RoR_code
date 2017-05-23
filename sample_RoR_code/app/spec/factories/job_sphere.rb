# JobSphere Factory
FactoryGirl.define do
  factory :job_sphere do
    id 1
    name 'Business'
  end
end
# == Schema Information
#
# Table name: job_spheres
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
