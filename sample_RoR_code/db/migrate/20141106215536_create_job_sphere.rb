class CreateJobSphere < ActiveRecord::Migration
  def up
    create_table :job_spheres do |t|
      t.string :name
      t.timestamps
    end
  end

  def down
    drop_table :job_spheres
  end
end
