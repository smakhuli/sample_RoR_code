class JobRegistration < ActiveRecord::Base
  has_one :job_fee
  belongs_to :account
  belongs_to :job_posting

  attr_accessible :start_date, :end_date, :job_fee_id

  validates_presence_of :account_id
  validates_presence_of :job_posting_id
  validates_presence_of :job_fee_id, :on => :update
  validates_presence_of :start_date, :on => :update
  validate :valid_start_date

  JOBS_OLD_GL_NUMBER = '1934-5-5-41000 (JOB posting)'
  JOBS_GL_NUMBER = '1934-5-6-41000 (JOB posting)'

  def self.find_or_create_job_registration(user, job_posting_id, job_fee_id)
    raise "account id required" unless user
    job_registration = JobRegistration.find_or_create_by_account_id_and_job_posting_id_and_job_fee_id(user.account.id, job_posting_id, job_fee_id)
    job_registration.reload
    job_registration
  end

  def calculate_end_date
    job_fee = JobFee.find_by_id(job_fee_id)
    return nil unless job_fee
    start_date + job_fee.number_of_months.months
  end

  def process_current
    due_now = self.job_posting_fee

    if due_now.cents > 0
      result = account.charge_braintree(due_now, "job-reg-#{id}")

      unless result.success?
        account.add_braintree_decline(result)
        return result
      end

      begin
        account.add_job_registration(job_posting.title, due_now)
      rescue => e
        ExceptionNotifier.notify(e)
      end

      begin
        account.add_braintree_success(result, JobRegistration::JOBS_GL_NUMBER, nil)
      rescue => e
        ExceptionNotifier.notify(e)
      end

      begin
        # Send the Receipt email
        JobMailer.job_registration_receipt(self).deliver
      rescue => e
        ExceptionNotifier.notify(e)
      end

      result
    end
  end

  def tr_data(redirect_url)
    account.create_customer unless account.braintree_customer_find
    account.update_customer

    if account.braintree_card_find
      Braintree::TransparentRedirect.update_customer_data(
          :redirect_url => redirect_url,
          :customer_id => account.braintree_customer_id,
          :customer => {
              :credit_card => {
                  :options => {
                      :update_existing_token => account.braintree_payment_method_token,
                      :verify_card => account.validate_card,
                      :verification_merchant_account_id => "globallegacy"
                  },
                  :billing_address => {
                      :options => {
                          :update_existing => true
                      }
                  }
              }
          }
      )
    else
      Braintree::TransparentRedirect.update_customer_data(
          :redirect_url => redirect_url,
          :customer_id => account.braintree_customer_id,
          :customer => {
              :credit_card => {
                  :token => account.braintree_payment_method_token,
                  :options => {
                      :verify_card => account.validate_card,
                      :verification_merchant_account_id => "globallegacy"
                  },
              }
          }
      )
    end
  end

  def job_posting_fee
    JobFee.find(job_fee_id).fee
  end

  def number_of_months
    job_fee = JobFee.find(job_fee_id)

    title_string = job_fee.number_of_months.to_s
    if job_fee.number_of_months == 1
      title_string += ' month'
    else
      title_string += ' months'
    end
    title_string
  end

  def pending?
    Time.zone.now < start_date
  end

  def open?
    Time.zone.now >= start_date and Time.zone.now <= end_date
  end

  def closed?
    Time.zone.now > end_date
  end

  def self.get_stats(year)
    job_registration_non_staff_count = 0
    job_registration_staff_count = 0
    job_registrations = JobRegistration.where('extract(year from created_at) = ?', year)
    job_registrations.each do |job_registration|
      if job_registration.job_posting
        job_registration_non_staff_count += 1 if job_registration.job_posting.complete? && !job_registration.job_posting.is_bethel_staff?
        job_registration_staff_count += 1 if job_registration.job_posting.complete? && job_registration.job_posting.is_bethel_staff?
      end
    end

    # returning an array with multiple values
    [job_registration_non_staff_count,
     job_registration_staff_count,
     JobPosting.where('extract(year from created_at) = ? and status = ?', year, "complete").count,
     JobPosting.where('extract(year from created_at) = ? and status = ?', year, "incomplete").count]
  end

  def self.get_stats_for_all_years
    job_registration_non_staff_count = 0
    job_registration_staff_count = 0
    JobRegistration.all.each do |job_registration|
      job_registration_non_staff_count += 1 if job_registration.job_posting && job_registration.job_posting.complete? && !job_registration.job_posting.is_bethel_staff?
      job_registration_staff_count += 1 if job_registration.job_posting && job_registration.job_posting.complete? && job_registration.job_posting.is_bethel_staff?
    end
    [job_registration_non_staff_count,
     job_registration_staff_count,
     JobPosting.where('status = ?', "complete").count,
     JobPosting.where('status = ?', "incomplete").count]
  end

  def self.total_paid(year)
    amount = Transaction.where("extract(year from updated_at) = ? and (gl_number = ? or gl_number = ?)", year, JobRegistration::JOBS_OLD_GL_NUMBER, JobRegistration::JOBS_GL_NUMBER).sum(:amount)*-1.to_money
    return 0.to_money if amount == -0.00.to_money
    amount
  end

  def self.total_paid_fiscal_year(year)
    fiscal_months = [8, 9, 10, 11, 12, 1, 2, 3, 4, 5, 6, 7]

    fiscal_amount = 0.to_money
    fiscal_months.each do |month|
      if month < 8
        search_year = year
      else
        search_year = year - 1
      end

      fiscal_amount += Transaction.where("extract(year from updated_at) = ? and extract(month from updated_at) = ? and (gl_number = ? or gl_number = ?)", search_year, month, JobRegistration::JOBS_OLD_GL_NUMBER, JobRegistration::JOBS_GL_NUMBER).sum(:amount)*-1.to_money
    end
    return 0.to_money if fiscal_amount == -0.00.to_money
    fiscal_amount
  end

  def self.total_paid_monthly(year, month)
    amount = Transaction.where("extract(year from updated_at) = ? and extract(month from updated_at) = ? and  (gl_number = ? or gl_number = ?)", year, month, JobRegistration::JOBS_OLD_GL_NUMBER, JobRegistration::JOBS_GL_NUMBER).sum(:amount)*-1.to_money
    return 0.to_money if amount == -0.00.to_money
    amount
  end

  def self.job_postings_by_amount(year)
    job_fee_counts = []
    job_fee_percents = []
    job_fee_total_count = 0
    JobFee.all.each_with_index do |job_fee, i|
      job_fee_counts[i] = JobRegistration.get_job_fee_count(job_fee.id, year)
      job_fee_total_count += JobRegistration.get_job_fee_count(job_fee.id, year).last
    end
    job_fee_counts.each_with_index do |job_fee_count, i|
      if job_fee_total_count > 0
        job_fee_percents[i] = ((job_fee_count[1].to_f/job_fee_total_count.to_f) * 100.to_f).round(2)
      else
        job_fee_percents[i] = 0.to_f.round(2)
      end
    end

    [job_fee_counts, job_fee_percents]
  end

  def self.job_postings_by_amount_all_years
    job_fee_counts = []
    job_fee_percents = []
    job_fee_total_count = 0
    JobFee.all.each_with_index do |job_fee, i|
      job_fee_counts[i] = JobRegistration.get_job_fee_count_all_years(job_fee.id)
      job_fee_total_count += JobRegistration.get_job_fee_count_all_years(job_fee.id).last
    end
    job_fee_counts.each_with_index do |job_fee_count, i|
      if job_fee_total_count > 0
        job_fee_percents[i] = ((job_fee_count[1].to_f/job_fee_total_count.to_f) * 100.to_f).round(2)
      else
        job_fee_percents[i] = 0.to_f.round(2)
      end
    end
    [job_fee_counts, job_fee_percents]
  end

  def self.get_job_fee_count(job_fee_id, year)
    [job_fee_id, JobRegistration.select { |jr| jr if jr.job_fee_id == job_fee_id && jr.job_posting && jr.job_posting.complete? && !jr.job_posting.is_bethel_staff? && jr.job_posting.created_at.year == year.to_i }.count]
  end

  def self.get_job_fee_count_all_years(job_fee_id)
    [job_fee_id, JobRegistration.select { |jr| jr if jr.job_fee_id == job_fee_id && jr.job_posting && jr.job_posting.complete? && !jr.job_posting.is_bethel_staff? }.count]
  end

  private

  def valid_start_date
    return if start_date.blank?
    if start_date < Date.current
      errors.add(:start_date, 'cannot be in the past.')
    end
  end

end

# == Schema Information
#
# Table name: job_registrations
#
#  id             :integer          not null, primary key
#  account_id     :integer
#  job_posting_id :integer
#  job_fee_id     :integer
#  start_date     :datetime
#  end_date       :datetime
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

