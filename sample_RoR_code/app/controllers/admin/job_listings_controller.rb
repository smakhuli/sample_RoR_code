class Admin::JobListingsController < Admin::BaseController

  skip_authorization_check

  # GET /admin/titles
  def index
    @job_postings = JobPosting.all_active
  end

end
