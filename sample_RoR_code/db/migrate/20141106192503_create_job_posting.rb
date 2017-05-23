class CreateJobPosting < ActiveRecord::Migration
  def up
    create_table :job_postings do |t|
      t.integer :employer_id
      t.integer :job_registration_id
      t.string :status
      t.string :title
      t.string :job_location
      t.float :latitude
      t.float :longitude
      t.string :job_type
      t.string :hours_per_week
      t.string :job_category
      t.text :job_description
      t.text :job_requirements
      t.text :job_nice_to_haves
      t.string :church_name
      t.string :church_url
      t.string :reports_to
      t.timestamps
    end
  end

  def down
    drop_table :job_postings
  end
end
