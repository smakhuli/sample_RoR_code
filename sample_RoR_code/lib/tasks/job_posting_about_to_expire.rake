require File.expand_path("../../../config/environment", __FILE__)

namespace :job_posting_about_to_expire do
  task :send_notifications do
    job_posting_ids = JobPosting.about_to_expire

    job_posting_ids.each do |job_posting_id|
      JobMailer.job_posting_about_to_expire(job_posting_id).deliver
    end

  end
end