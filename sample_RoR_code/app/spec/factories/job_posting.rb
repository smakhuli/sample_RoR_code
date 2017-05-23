# JobPosting Factory
FactoryGirl.define do
  factory :job_posting do
    title 'Youth Pastor'
    job_description 'Molds and shapes the future generation of christians'
    job_requirements 'Loves children'
    employer_id = 1
  end
end
# == Schema Information
#
# Table name: job_postings
#
#  id                  :integer          not null, primary key
#  employer_id         :integer
#  job_registration_id :integer
#  status              :string(255)
#  title               :string(255)
#  job_location        :string(255)
#  latitude            :float
#  longitude           :float
#  job_type            :string(255)
#  hours_per_week      :string(255)
#  job_category        :string(255)
#  job_description     :text
#  job_requirements    :text
#  job_nice_to_haves   :text
#  church_name         :string(255)
#  church_url          :string(255)
#  reports_to          :string(255)
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
