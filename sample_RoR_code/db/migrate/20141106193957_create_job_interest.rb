class CreateJobInterest < ActiveRecord::Migration
  def up
    create_table :job_interests do |t|
      t.integer :job_posting_id
      t.integer :applicant_id
      t.string :name
      t.string :job_location
      t.float :latitude
      t.float :longitude
      t.string :phone_number
      t.string :email
      t.text :why_me
      t.datetime :start_date
      t.timestamps
    end
  end

  def down
    drop_table :job_interests
  end
end
