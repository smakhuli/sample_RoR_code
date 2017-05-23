class CreateJobFee < ActiveRecord::Migration
  def up
    create_table :job_fees do |t|
      t.integer :number_of_months
      t.decimal :fee, :precision => 10, :scale => 2, :default => 0.0
      t.timestamps
    end
  end

  def down
  end
end
