class JobInterest < ActiveRecord::Base
  belongs_to :job_posting

  attr_accessible :name, :applicant_id, :job_posting_id, :phone_number, :email, :why_me, :start_date

  validates_presence_of :name

  def is_owner?(user_id)
    return true if applicant_id == user_id
    false
  end

  def interested?
    status == 'interested'
  end

  def contacted?
    status == 'contacted'
  end

  def hired?
    status == 'hired'
  end

  def self.total_interests(year)
    JobInterest.where('extract(year from created_at) = ?', year).count
  end

  def self.total_interests_all_years
    JobInterest.all.count
  end

  def self.total_interested(year)
    JobInterest.where('extract(year from updated_at) = ? and status = ?', year, 'interested').count
  end

  def self.total_interested_all_years
    JobInterest.where('status = ?', 'interested').count
  end

  def self.total_contacted(year)
    JobInterest.where('extract(year from updated_at) = ? and status = ?', year, 'contacted').count
  end

  def self.total_contacted_all_years
    JobInterest.where('status = ?', 'contacted').count
  end

  def self.total_hired(year)
    JobInterest.where('extract(year from updated_at) = ? and status = ?', year, 'hired').count
  end

  def self.total_hired_all_years
    JobInterest.where('status = ?', 'hired').count
  end

  def get_name_value(user)
    return name if name.present?
    user.full_name
  end

  def get_phone_value(user)
    return phone_number if phone_number.present?
    return user.profile.phone if user.profile && user.profile.phone
    nil
  end

  def get_email_value(user)
    return email if email.present?
    user.email
  end

  def self.my_job_interests(user_id)
    where("applicant_id = ?", user_id)
  end

  def self.my_job_posting_interests(user_id)
    job_interests = JobInterest.where("applicant_id = ?", user_id)
    job_postings = []
    if job_interests.any?
      job_interests.each do |job_interest|
        job_posting = JobPosting.find_by_id(job_interest.job_posting_id)
        if job_posting
          job_postings << job_posting unless job_posting.expired?
        end
      end
    end
    job_postings
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

