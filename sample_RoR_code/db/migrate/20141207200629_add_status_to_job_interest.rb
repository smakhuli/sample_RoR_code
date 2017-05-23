class AddStatusToJobInterest < ActiveRecord::Migration
  def change
    add_column :job_interests, :status, :string
  end
end
