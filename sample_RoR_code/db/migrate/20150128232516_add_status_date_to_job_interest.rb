class AddStatusDateToJobInterest < ActiveRecord::Migration
  def change
    add_column :job_interests, :status_date, :datetime
  end
end
