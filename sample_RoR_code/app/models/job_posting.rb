class JobPosting < ActiveRecord::Base
  #has_many :job_interests
  has_many :job_sphereships, dependent: :destroy
  has_many :job_spheres, through: :job_sphereships
  has_one :job_registration
  has_many :job_interests
  has_many :notifications, :as => :notifiable, :dependent => :destroy

  attr_accessible :title, :employer_id, :job_type, :hours_per_week, :job_location, :job_category, :job_description, :job_requirements, :job_nice_to_haves
  attr_accessible :church_name, :church_url, :reports_to, :job_registration_id

  validates_presence_of :title #, :job_type, :job_description, :job_requirements

  include PgSearch
  pg_search_scope :search,
                  :against => {
                      :title => "A",
                      :job_location => "B",
                      :job_description => "C",
                      :job_requirements => "D"
                  },
                  :using => {
                      :tsearch => {
                          :dictionary => "english",
                          :prefix => true
                      }
                  },
                  :associated_against => {
                      :job_spheres => [:name]
                  }

  def is_owner?(user_id)
    return true if employer_id == user_id
    false
  end

  def self.my_job_postings(user_id)
    where("employer_id = ?", user_id)
  end

  def self.incomplete_job_postings(user_id)
    where("employer_id = ? and status = ?", user_id, 'incomplete')
  end

  def self.pending_job_postings(user_id)
    job_postings = []
    where("employer_id = ? and status = ?", user_id, 'complete').each do |job_posting|
      job_postings << job_posting if job_posting.job_registration.pending?
    end
    job_postings
  end

  def self.open_job_postings(user_id)
    job_postings = []
    where("employer_id = ? and status = ?", user_id, 'complete').each do |job_posting|
      job_postings << job_posting if job_posting.job_registration.open?
    end
    job_postings
  end

  def self.closed_job_postings(user_id)
    job_postings = []
    where("employer_id = ? and status = ?", user_id, 'complete').each do |job_posting|
      job_postings << job_posting if job_posting.job_registration.closed?
    end
    job_postings
  end

  def self.completed_job_postings(user_id)
    where("status = ? and employer_id <> ?", 'complete', user_id)
  end

  def self.all_completed_job_postings
    where("status = ?", 'complete')
  end

  def self.all_completed_job_postings_by_year(year)
    where("extract(year from created_at) = ? and status = ?", year, 'complete').order("created_at desc")
  end

  def self.all_completed_job_postings_all_years
    where("status = ?", 'complete').order("created_at desc")
  end

  def self.new_job_postings(completed_job_postings)
    job_postings = []
    completed_job_postings.each do |job_posting|
      if job_posting.new?
        job_postings << job_posting if job_posting.job_registration.open?
      end
    end
    job_postings
  end

  def self.available_job_postings(completed_job_postings)
    job_postings = []
    completed_job_postings.each do |job_posting|
      if !job_posting.new?
        job_postings << job_posting if job_posting.job_registration.open?
      end
    end
    job_postings
  end

  def self.expired_job_postings(completed_job_postings)
    job_postings = []
    completed_job_postings.each do |job_posting|
      if !job_posting.new?
        job_postings << job_posting if job_posting.job_registration.closed?
      end
    end
    job_postings
  end

  def incomplete?
    status == 'incomplete'
  end

  def complete?
    status == 'complete'
  end

  def new?
    job_registration.start_date.to_date > 1.week.ago.to_date
  end

  def update_status
    self.status = 'complete'
    self.save!
  end

  def self.duplicate(id)
    job_posting = JobPosting.find(id)
    new_job_posting = job_posting.dup
    new_job_posting.status = 'incomplete'
    new_job_posting.job_registration_id = nil

    if new_job_posting.save
      job_posting.job_spheres.each do |job_sphere|
        new_job_posting.job_spheres << job_sphere
      end
      return new_job_posting
    end

    return false
  end

  # this method returns the job interest if the user has expressed interest in a job posting
  def job_interest?(user_id)
    return false unless job_interests.any?
    job_interests.each do |job_interest|
      if job_interest.applicant_id == user_id
        return job_interest
      end
    end
    false
  end

  def is_applicant?(params)
    params[:job_interest] == 'job_interest'
  end

  def is_employer?(params)
    params[:employer] == 'employer'
  end

  def self.about_to_expire
    job_posting_ids = []
    where("status = ?", 'complete').each do |job_posting|
      job_posting_ids << job_posting.id if job_posting.job_registration.end_date.to_date == 1.week.from_now.to_date
    end
    job_posting_ids
  end

  def expired?
    complete? && job_registration.end_date < Time.zone.now
  end

  def self.expired
    job_postings = []
    where("status = ?", 'complete').each do |job_posting|
      #ap job_registration.end_date.to_date
      #ap 1.day.ago.to_date
      job_postings << job_posting if job_posting.job_registration.end_date.to_date == 1.day.ago.to_date
    end
    job_postings
  end

  def self.have_expired(year)
    JobPosting.select { |jp| jp if jp.created_at.year == year.to_i && jp.complete? && jp.job_registration.end_date < Time.zone.now }
  end

  def self.expired_and_no_interests(year)
    JobPosting.select { |jp| jp if jp.created_at.year == year.to_i && jp.complete? && jp.job_registration.end_date < Time.zone.now && jp.job_interests.count == 0 }
  end

  def self.expired_not_staff_and_no_interests(year)
    JobPosting.select { |jp| jp if jp.created_at.year == year.to_i && jp.complete? && jp.job_registration.end_date < Time.zone.now && jp.job_interests.count == 0 && !jp.is_bethel_staff?}
  end

  def self.expired_staff_and_no_interests(year)
    JobPosting.select { |jp| jp if jp.created_at.year == year.to_i && jp.complete? && jp.job_registration.end_date < Time.zone.now && jp.job_interests.count == 0 && jp.is_bethel_staff?}
  end

  def self.active(year)
    JobPosting.select { |jp| jp if jp.created_at.year == year.to_i && jp.complete? && jp.job_registration.end_date > Time.zone.now }
  end

  def self.all_active
    joins(:job_registration).where("job_registrations.end_date > ? and status = ?", Time.zone.now, 'complete' )
  end

  def self.send_active_job_postings_info(email)
    JobMailer.active_job_postings(email).deliver
  end

  def self.active_no_staff(year)
    JobPosting.select { |jp| jp if jp.created_at.year == year.to_i && jp.complete? && jp.job_registration.end_date > Time.zone.now && !jp.is_bethel_staff?}
  end

  def self.active_staff(year)
    JobPosting.select { |jp| jp if jp.created_at.year == year.to_i && jp.complete? && jp.job_registration.end_date > Time.zone.now && jp.is_bethel_staff?}
  end

  def self.active_and_no_interests(year)
    JobPosting.select { |jp| jp if jp.created_at.year == year.to_i && jp.complete? && jp.job_registration.end_date > Time.zone.now && jp.job_interests.count == 0}
  end

  def self.active_not_staff_and_no_interests(year)
    JobPosting.select { |jp| jp if jp.created_at.year == year.to_i && jp.complete? && jp.job_registration.end_date > Time.zone.now && jp.job_interests.count == 0 && !jp.is_bethel_staff?}
  end

  def self.active_staff_and_no_interests(year)
    JobPosting.select { |jp| jp if jp.created_at.year == year.to_i && jp.complete? && jp.job_registration.end_date > Time.zone.now && jp.job_interests.count == 0 && jp.is_bethel_staff?}
  end

  def expressed_interest
    job_interests.where('status = ?', 'interested').order("created_at desc")
  end

  def contacted
    job_interests.where('status = ?', 'contacted').order("created_at desc")
  end

  def hired
    job_interests.where('status = ?', 'hired').order("created_at desc")
  end

  def self.completed_postings_by_sphere(sphere_name)
    completed_job_postings = JobPosting.all_completed_job_postings
    sphere_job_postings = []

    completed_job_postings.each do |job_posting|
      job_posting.job_spheres.each do |job_sphere|
        sphere_job_postings << job_posting if job_sphere.name == sphere_name && !job_posting.expired?
      end
    end

    sphere_job_postings
  end

  def self.job_postings_with_no_interests(year)
    job_postings = JobPosting.all_completed_job_postings_by_year(year)
    job_postings.select { |job_posting| job_posting.job_interests.count == 0 }.count
  end

  def self.job_postings_with_no_interests_all_years
    job_postings = JobPosting.all_completed_job_postings_all_years
    job_postings.select { |job_posting| job_posting.job_interests.count == 0 }.count
  end

  def is_bethel_staff?
    return false unless User.find_by_id(employer_id)
    User.find(employer_id).is_bethel_staff?
  end

  def self.most_recent(number_of_jobs)
    JobPosting.where('status = ?', 'complete').order("updated_at DESC").limit(number_of_jobs)
  end

  def self.list_most_recent(number_of_jobs)
    JobPosting.most_recent(number_of_jobs).map { |job_posting| "#{job_posting.title} - #{job_posting.job_location} - #{job_posting.church_name}"}.each do |jp|
      puts jp
    end
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

