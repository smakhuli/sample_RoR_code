class CreateJobRegistration < ActiveRecord::Migration
  def up
    create_table :job_registrations do |t|
      t.integer :account_id
      t.integer :job_posting_id
      t.integer :job_fee_id
      t.datetime :start_date
      t.datetime :end_date
      t.timestamps
    end
  end

  def down
  end
end
