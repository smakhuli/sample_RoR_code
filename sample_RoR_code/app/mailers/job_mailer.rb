class JobMailer < ActionMailer::Base
  add_template_helper(ApplicationHelper)
  default :from => "Global Legacy <registration@globallegacy.com>"

  layout 'email_jobs'

  def job_registration_receipt(job_registration)
    @user = job_registration.account.user
    @job_registration = job_registration
    subject = "GL Job Posting Receipt"
    mail(:to => @user.email, :subject => subject)
  end

  def job_interest_employer_notification(job_posting, job_interest)
    @user = job_posting.job_registration.account.user
    @job_posting = job_posting
    @job_interest = job_interest
    subject = "GL Job Interest Notification for #{job_posting.title} Job Posting"
    mail(:to => @user.email, :subject => subject)
  end

  def job_posting_about_to_expire(job_posting_id)
    @job_posting = JobPosting.find_by_id(job_posting_id)
    if @job_posting
      @user = @job_posting.job_registration.account.user
      subject = "Your #{@job_posting.title} posting at GL Jobs is about to expire"
      mail(:to => @user.email, :subject => subject)
    end
  end

  def job_posting_expired_notice(job_posting_id)
    @job_posting = JobPosting.find_by_id(job_posting_id)
    if @job_posting
      @user = @job_posting.job_registration.account.user
      subject = "GL Job Posting Expired: #{@job_posting.title}"
      mail(:to => @user.email, :subject => subject)
    end
  end

  def active_job_postings(email)
    @job_postings = JobPosting.all_active
    mail(:to => email, :subject => 'Active Job Postings') if User.find_by_email(email) && @job_postings.any?
  end

end