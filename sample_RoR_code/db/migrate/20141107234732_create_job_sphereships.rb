class CreateJobSphereships < ActiveRecord::Migration
  def self.up
    create_table :job_sphereships do |t|
      t.integer :job_posting_id
      t.integer :job_sphere_id

      t.timestamps
    end
  end

  def self.down
    drop_table :job_sphereships
  end
end
