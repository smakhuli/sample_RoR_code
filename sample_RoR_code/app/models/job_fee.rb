class JobFee < ActiveRecord::Base
  money_column :fee

  attr_accessible :number_of_months, :fee

  validates_presence_of :number_of_months, :fee

  def self.job_fee_options
    job_fees = []

    JobFee.all.each do |job_fee|
      job_fees << [job_fee.title, job_fee.id]
    end

    job_fees
  end

  def title
    title_string = ""
    if number_of_months == 1
      title_string += "<span class='price'>#{fee.to_currency}</span><span class='months'>" + number_of_months.to_s + " month</span>"
    else
      title_string += "<span class='price'>#{fee.to_currency}</span><span class='months'>" + number_of_months.to_s + " months</span>"
    end
    title_string.html_safe
  end

end

# == Schema Information
#
# Table name: job_fees
#
#  id               :integer          not null, primary key
#  number_of_months :integer
#  fee              :decimal(10, 2)   default(0.0)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

