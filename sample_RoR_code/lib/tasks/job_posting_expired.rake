require File.expand_path("../../../config/environment", __FILE__)

namespace :job_posting_expired do
  task :send_notifications do
    job_posting_ids = JobPosting.expired

    job_posting_ids.each do |job_posting_id|
      JobMailer.job_posting_expired_notice(job_posting_id).deliver
    end

  end
end