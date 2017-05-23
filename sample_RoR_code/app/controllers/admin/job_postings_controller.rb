class Admin::JobPostingsController < Admin::BaseController

  authorize_resource :class => "JobPosting"

  def index
    @job_postings = JobPosting.all_active
  end

  def show
    @job_posting = JobPosting.find_by_id(params[:id])

    if @job_posting
      @years = []
      @job_interests_expressed_interest = @job_posting.expressed_interest
      @job_interests_contacted = @job_posting.contacted
      @job_interests_hired = @job_posting.hired
      @job_fee_id = JobFee.find(params[:job_fee_id]) if params[:job_fee_id].present?
    else
      redirect_to(registration_job_postings_admin_job_reports_path, :notice => 'Job Posting was not found.')
    end
  end

  def edit
    @job_posting = JobPosting.find(params[:id])
  end

  # PUT /titles/1
  def update
    @job_posting = JobPosting.find(params[:id])

    if @job_posting.update_attributes(params[:job_posting])
      redirect_to(admin_job_postings_path, :notice => 'Job Posting was successfully updated.')
    else
      render :action => "edit"
    end
  end

end

