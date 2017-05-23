class JobPostingsController < ApplicationController

  skip_authorization_check

  def index
    if user_signed_in?
      if params["job_posting"] == "post a job"
        render "post_a_job"
      else
        @incomplete_job_postings = JobPosting.order("created_at desc").incomplete_job_postings(current_user.id)
        @pending_job_postings = JobPosting.order("created_at desc").pending_job_postings(current_user.id)
        @open_job_postings = JobPosting.order("created_at desc").open_job_postings(current_user.id)
        @closed_job_postings = JobPosting.order("created_at desc").closed_job_postings(current_user.id)
      end
    else
      if params["job_posting"] == "post a job"
        render "post_a_job"
      else
        session[:url_back] = request.url
        flash[:alert] = 'Please sign in to Post a Job.'
        redirect_to new_user_session_url
      end
    end
  end

  # GET /admin/titles/1
  def show
    @job_posting = JobPosting.find_by_id(params[:id])

    if @job_posting
      @job_interests_expressed_interest = @job_posting.expressed_interest
      @job_interests_contacted = @job_posting.contacted
      @job_interests_hired = @job_posting.hired
      @job_fee_id = JobFee.find(params[:job_fee_id]) if params[:job_fee_id].present?
      #raise "#{@job_interests_expressed_interest.inspect} - #{@job_interests_contacted.inspect} - #{@job_interests_hired.inspect}"
    else
      redirect_to(job_postings_path, :notice => 'Job Posting was not found.')
    end
  end

  # GET /admin/titles/new
  def new
    if user_signed_in?
      @job_posting = JobPosting.new
      @job_spheres = JobSphere.order("name")
      @job_fee = JobFee.find(params[:job_fee_id]) if params[:job_fee_id].present?
    else
      session[:url_back] = request.url
      flash[:alert] = 'Please sign in to Post a Job.'
      redirect_to new_user_session_url
    end
  end

  # GET /admin/titles/1/edit
  def edit
    if user_signed_in?
      @job_posting = JobPosting.find_by_id(params[:id])

      if @job_posting
        authorize! :edit, @job_posting
        @job_spheres = JobSphere.order("name")
      else
        redirect_to(job_postings_path, :notice => 'Job Posting was not found.')
      end
    else
      session[:url_back] = request.url
      flash[:alert] = 'Please sign in to Edit Job Posting.'
      redirect_to new_user_session_url
    end
  end

  # POST /titles
  def create
    @job_posting = JobPosting.new(params[:job_posting])
    @job_posting.status = 'incomplete'

    if @job_posting.save
      params[:job_posting][:job_sphere_ids].each do |job_sphere_id|
        unless job_sphere_id.blank? || JobSphere.find_by_id(job_sphere_id).nil?
          JobSphereship.build_job_sphereship(@job_posting, job_sphere_id)
        end
      end

      if params[:job_posting][:job_fee_id].present?
        redirect_to(job_posting_path(@job_posting, job_fee_id: params[:job_posting][:job_fee_id]), :notice => 'Job Posting was successfully created.')
      else
        redirect_to(job_posting_path(@job_posting), :notice => 'Job Posting was successfully created.')
      end
    else
      render :action => "new"
    end
  end

  # PUT /titles/1
  def update
    #raise params.inspect
    @job_posting = JobPosting.find(params[:id])

    if @job_posting.update_attributes(params[:job_posting])
      # Delete all Job Sphereships tied to this Job Posting
      JobSphereship.where("job_posting_id = ?", @job_posting.id).each do |job_sphereship|
        job_sphereship.delete
      end

      # Rebuild Job Sphereships for this Job Posting
      params[:job_posting][:job_sphere_ids].each do |job_sphere_id|
        unless job_sphere_id.blank? || JobSphere.find_by_id(job_sphere_id).nil?
          JobSphereship.build_job_sphereship(@job_posting, job_sphere_id)
        end
      end

      redirect_to(job_posting_path(@job_posting), :notice => 'Job Posting was successfully updated.')
    else
      render :action => "edit"
    end
  end

  # DELETE /titles/1
  def destroy
    @job_posting = JobPosting.find(params[:id])
    @job_posting.destroy

    redirect_to(job_postings_path, :notice => 'Job Posting was successfully deleted.')
  end

  def view_interests
    @job_posting = JobPosting.find(params[:id])
    @job_interests = @job_posting.job_interests
  end

  def duplicate
    @job_posting = JobPosting.find_by_id(params[:id])

    if @job_posting
      duplicate_job_posting = JobPosting.duplicate(params[:id])
      if duplicate_job_posting
        redirect_to(edit_job_posting_path(duplicate_job_posting, duplicated: true), :notice => "#{JobPosting.find(params[:id]).title} Job Posting was successfully duplicated.")
      else
        redirect_to(job_postings_path, :notice => 'Job Posting was not duplicated.')
      end
    else
      redirect_to(job_postings_path, :notice => 'Job Posting was not duplicated.')
    end
  end

end