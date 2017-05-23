class JobSphereship < ActiveRecord::Base
  attr_accessible # none

  belongs_to :job_posting, touch: true
  belongs_to :job_sphere, touch: true

  def self.build_job_sphereship(job_posting, job_sphere_id)
    job_sphereship = JobSphereship.new
    job_sphereship.job_posting = job_posting
    job_sphereship.job_sphere = JobSphere.find_by_id(job_sphere_id)
    job_sphereship.save!
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

