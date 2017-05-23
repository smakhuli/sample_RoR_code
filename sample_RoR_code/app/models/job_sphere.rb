class JobSphere < ActiveRecord::Base
  has_many :job_sphereships, dependent: :destroy
  has_many :job_postings, through: :job_sphereships

  attr_accessible :name

  validates_presence_of :name
  validates_uniqueness_of :name

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

