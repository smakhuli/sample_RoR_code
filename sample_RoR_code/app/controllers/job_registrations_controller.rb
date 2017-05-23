class JobRegistrationsController < ApplicationController

  skip_authorization_check

  before_filter { @selected_nav = "jobposting" }

  # GET /admin/titles/new
  def new
    raise CanCan::AccessDenied unless user_signed_in?
    @job_registration = JobRegistration.find_or_create_job_registration(current_user, params[:job_posting_id], params[:job_fee_id])
    @job_fees = JobFee.order("number_of_months")
    redirect_to(edit_job_registration_path(@job_registration))
  end

  def edit
    raise CanCan::AccessDenied unless user_signed_in?
    @job_registration = current_user.account.job_registrations.find_by_id(params[:id])

    unless @job_registration
      redirect_to(job_postings_path, :notice => 'Job Registration was not found.')
    else
      if JobPosting.find(@job_registration.job_posting_id).complete?
        redirect_to(job_postings_path, :notice => 'Job Registration cannot be changed for completed Job Posting.')
      end
    end
  end

  def update
    raise CanCan::AccessDenied unless user_signed_in?
    @job_registration = current_user.account.job_registrations.find(params[:id])

    if @job_registration.update_attributes(params[:job_registration])
      @job_registration.end_date = @job_registration.calculate_end_date
      if @job_registration.save
        unless current_user.is_bethel_staff?
          job_posting = @job_registration.job_posting
          job_posting.job_registration_id = @job_registration.id
          job_posting.save!
          redirect_to job_checkout_job_registration_path(@job_registration)
        else
          #raise "GOT HERE"
          job_posting = @job_registration.job_posting
          job_posting.update_status unless job_posting.complete?
          redirect_to(job_receipt_job_registration_path(@job_registration))
        end
      else
        redirect_to(job_postings_path, :notice => 'Job Registration was not updated.')
      end
    else
      render :action => "edit"
    end
  end

  def job_checkout
    raise CanCan::AccessDenied unless user_signed_in?
    @job_registration = current_user.account.job_registrations.find(params[:id])
  end

  def job_charge_on_file
    raise CanCan::AccessDenied unless user_signed_in?
    @job_registration = current_user.account.job_registrations.find(params[:id])
    @result = @job_registration.process_current
    if @result.success?
      job_posting = @job_registration.job_posting
      unless job_posting.complete?
        job_posting.update_status
      end
      redirect_to(job_receipt_job_registration_path(@job_registration))
    else
      render :action => "job_checkout"
    end
  end

  def job_receipt
    raise CanCan::AccessDenied unless user_signed_in?
    @job_registration = current_user.account.job_registrations.find(params[:id])
  end

  def job_confirm
    raise CanCan::AccessDenied unless user_signed_in?
    @result = Braintree::TransparentRedirect.confirm(request.query_string)
    @job_registration = current_user.account.job_registrations.find(params[:id])
    if @result.success?
      @result = @job_registration.process_current
      if @result.success?
        job_posting = @job_registration.job_posting
        unless job_posting.complete?
          job_posting.update_status
        end
        redirect_to(job_receipt_job_registration_path(@job_registration))
      else
        @show_new_card_div = true
        render :action => "job_checkout"
      end
    else
      @show_new_card_div = true
      @job_registration.account.add_braintree_card_validation_failure(@result)
      render :action => "job_checkout"
    end
  end

end

