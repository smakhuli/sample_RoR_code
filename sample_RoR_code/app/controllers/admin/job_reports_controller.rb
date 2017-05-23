class Admin::JobReportsController < Admin::BaseController

  before_filter :get_years

  def index
    authorize! :read, :job_reports
  end

  def registration_totals
    authorize! :read, :job_reports
    params[:year] ||= 2017

    result = JobRegistration.get_stats(params[:year])

    @total_registered = result[0]
    @total_staff_registered = result[1]
    @total_paid = JobRegistration.total_paid(params[:year])
    @year = params[:year]
    @months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December']
  end

  def registration_stats
    authorize! :read, :job_reports
    params[:year] ||= 2017

    result = JobRegistration.get_stats(params[:year])

    @total_non_staff_registered = result[0]
    @total_staff_registered = result[1]
    @total_registered = result[0] + result[1]
    @job_postings_complete = result[2]
    @job_postings_incomplete = result[3]
    @job_interest_yearly_total = JobInterest.total_interests(params[:year])
    @job_interest_total = JobInterest.count

    @job_fee_counts = JobRegistration.job_postings_by_amount(params[:year])[0]
    @job_fee_percents = JobRegistration.job_postings_by_amount(params[:year])[1]
    @total_interested = JobInterest.total_interested(params[:year])
    @total_contacted = JobInterest.total_contacted(params[:year])
    @total_hired = JobInterest.total_hired(params[:year])

    @total_paid = JobRegistration.total_paid(params[:year])

    @no_interests = JobPosting.job_postings_with_no_interests(params[:year])
    if @job_postings_complete > 0
      @no_interests_percent = (@no_interests.to_f/@job_postings_complete.to_f  * 100.to_f).round(2)
    else
      @no_interests_percent = 0.to_f.round(2)
    end
    @expired = JobPosting.have_expired(params[:year]).count
    @active = JobPosting.active(params[:year]).count
    @expired_not_staff_no_interests = JobPosting.expired_not_staff_and_no_interests(params[:year]).count
    @active_not_staff_no_interests = JobPosting.active_not_staff_and_no_interests(params[:year]).count
    @expired_staff_no_interests = JobPosting.expired_staff_and_no_interests(params[:year]).count
    @active_staff_no_interests = JobPosting.active_staff_and_no_interests(params[:year]).count
    @expired_no_interests = JobPosting.expired_and_no_interests(params[:year]).count
    @active_no_interests = JobPosting.active_and_no_interests(params[:year]).count
  end

  def registration_stats_all_years
    authorize! :read, :job_reports
    params[:year] ||= 2017
    @years = [2015, 2016, 2017, 2018]

    @result_by_year = []
    @result_by_fiscal_year = []
    @total_for_all_years = 0.to_money

    @years.each_with_index do |year, index|
      @result_by_year[index] = JobRegistration.total_paid(year)
      @result_by_fiscal_year[index] = JobRegistration.total_paid_fiscal_year(year)
      @total_for_all_years += @result_by_year[index]
    end

    result = JobRegistration.get_stats_for_all_years

    @total_non_staff_registered = result[0]
    @total_staff_registered = result[1]
    @total_registered = result[0] + result[1]
    @job_postings_complete = result[2]
    @job_postings_incomplete = result[3]
    @job_fee_counts = JobRegistration.job_postings_by_amount_all_years[0]
    @job_fee_percents = JobRegistration.job_postings_by_amount_all_years[1]
    @no_interests = JobPosting.job_postings_with_no_interests_all_years
    if @job_postings_complete > 0
      @no_interests_percent = (@no_interests.to_f/@job_postings_complete.to_f  * 100.to_f).round(2)
    else
      @no_interests_percent = 0.to_f.round(2)
    end

    @total_interested = JobInterest.total_interested_all_years
    @total_contacted = JobInterest.total_contacted_all_years
    @total_hired = JobInterest.total_hired_all_years
    @total_interests = JobInterest.total_interests_all_years
  end

  def registration_job_postings
    authorize! :read, :job_reports
    params[:year] ||= 2017

    @job_postings = JobPosting.all_completed_job_postings_by_year(params[:year])
  end

  private

  def get_years
    @years = ['2017', '2016', '2015']
  end
end