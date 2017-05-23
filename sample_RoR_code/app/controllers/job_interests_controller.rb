class JobInterestsController < ApplicationController

  skip_authorization_check

  def index
    @completed_job_postings = JobPosting.all_completed_job_postings

    if user_signed_in? && params[:commit] == "You have #{JobInterest.my_job_posting_interests(current_user.id).count} Job Interests"
      @completed_job_postings = JobInterest.my_job_posting_interests(current_user.id)
      params[:search] = 'My Job Posting Interests'
    elsif JobSphere.all.map(&:name).include?(params[:commit])
        @completed_job_postings = JobPosting.completed_postings_by_sphere(params[:commit])
        params[:search] = params[:commit] if @completed_job_postings.any?
    else
        if params[:search].present?
          @completed_job_postings = @completed_job_postings.search(params[:search])
          @new_job_postings = JobPosting.new_job_postings(@completed_job_postings)
          @completed_job_postings = JobPosting.available_job_postings(@completed_job_postings)
        end
    end

    @new_job_postings = JobPosting.new_job_postings(@completed_job_postings) unless @new_job_postings.present?
    @other_job_postings = JobPosting.available_job_postings(@completed_job_postings)
    @expired_job_postings = JobPosting.expired_job_postings(@completed_job_postings)
  end

  # GET /admin/titles/1
  def show
    if user_signed_in?
      @job_interest = JobInterest.find_by_id(params[:id])

      if @job_interest
        @job_posting = JobPosting.find(@job_interest.job_posting_id)
      else
        redirect_to(job_interests_path, :notice => "Job Interest #{params[:id]} not found.")
      end
    else
      session[:url_back] = request.url
      flash[:alert] = 'Please sign in.'
      redirect_to new_user_session_url
    end
  end

  # GET /admin/titles/new
  def new
    if user_signed_in?
      @job_posting_id = params[:job_posting_id]
      @job_posting = JobPosting.find(params[:job_posting_id])

      # Check to see if user has expressed interest already
      if @job_posting.job_interests.where("applicant_id = ?", current_user.id).any?
        @job_interest = @job_posting.job_interests.where("applicant_id = ?", current_user.id).first
        redirect_to(edit_job_interest_path(@job_interest), :notice => 'You have already expressed Interest in this Job Posting.')
        return
      else
        @job_interest = JobInterest.new
      end

      #raise "#{@job_posting_id} - #{@job_posting.inspect} - #{@job_interest.inspect}"
    else
      session[:url_back] = request.url
      flash[:alert] = 'Please sign in.'
      redirect_to new_user_session_url
    end
  end

  # GET /admin/titles/1/edit
  def edit
    if user_signed_in?
      @job_interest = JobInterest.find_by_id(params[:id])

      if @job_interest
        authorize! :edit, @job_interest
        @job_posting = JobPosting.find(@job_interest.job_posting_id)
        @job_posting_id = @job_posting.id
      else
        redirect_to(job_interests_path, :notice => "Job Interest #{params[:id]} not found.")
      end
    else
      session[:url_back] = request.url
      flash[:alert] = 'Please sign in.'
      redirect_to new_user_session_url
    end
  end

  # POST /titles
  def create
    @job_interest = JobInterest.new(params[:job_interest])
    @job_posting = JobPosting.find(params[:job_interest][:job_posting_id])

    #raise User.find_by_id(@job_posting.employer_id).inspect
    if @job_interest.save
      @job_interest.status = 'interested'
      @job_interest.status_date = Time.zone.now
      @job_interest.save!

      begin
        # Send Job Interest Notification to Employer
        JobMailer.job_interest_employer_notification(@job_posting, @job_interest).deliver
      rescue => e
        ExceptionNotifier.notify(e)
      end

      begin
        # Create employer notification
        if User.find_by_id(@job_posting.employer_id)
          @job_posting.notifications.create(:user_id => @job_posting.employer_id)
        end
      rescue => e
        #raise e.inspect
        ExceptionNotifier.notify(e)
      end

      redirect_to(job_interest_path(@job_interest, firsttime: true), :notice => 'Job Interest was successfully created.')
    else
      render :action => "new"
    end
  end

  # PUT /titles/1
  def update
    @job_interest = JobInterest.find(params[:id])

    if @job_interest.update_attributes(params[:job_interest])
      redirect_to(job_interest_path(@job_interest), :notice => 'Job Interest was successfully updated.')
    else
      render :action => "edit"
    end
  end

  # DELETE /titles/1
  def destroy
    @job_interest = JobInterest.find(params[:id])
    @job_interest.destroy

    redirect_to(job_interests_path, :notice => 'Job Interest was successfully deleted.')
  end

  def contacted
    @job_interest = JobInterest.find(params[:id])
    @job_posting = @job_interest.job_posting
    @job_interest.status = 'contacted'
    @job_interest.status_date = Time.zone.now

    if @job_interest.save
      redirect_to(job_posting_path(@job_posting), :notice => 'Job Interest status has been set to contacted.')
    else
      redirect_to(job_posting_path(@job_posting), :notice => 'Job Interest was not updated.')
    end
  end

  def hired
    @job_interest = JobInterest.find(params[:id])
    @job_posting = @job_interest.job_posting
    @job_interest.status = 'hired'
    @job_interest.status_date = Time.zone.now

    if @job_interest.save
      redirect_to(job_posting_path(@job_posting), :notice => 'Job Interest status has been set to hired.')
    else
      redirect_to(job_posting_path(@job_posting), :notice => 'Job Interest was not updated.')
    end
  end
end