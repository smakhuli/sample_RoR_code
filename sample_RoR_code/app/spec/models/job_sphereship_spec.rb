job_posting_spec.rbrequire 'spec_helper'

describe JobSphereship do

  context 'fields' do
    it { should have_db_column(:job_posting_id).of_type(:integer) }
    it { should have_db_column(:job_sphere_id).of_type(:integer) }
  end

  before(:each) do
    @job_posting = FactoryGirl.build(:job_posting)
    @job_sphere = FactoryGirl.build(:job_sphere)
    @job_sphereship = FactoryGirl.build(:job_sphereship)
  end

  context 'validations' do

    it 'should be valid' do
      @job_sphereship.should be_valid
    end

  end

  context 'build' do

    it 'should be able to build job_sphereship' do
      JobSphereship.count.should == 0

      @job_posting.save!
      @job_sphere.save!

      JobSphereship.build_job_sphereship(@job_posting, @job_sphere.id).should be_true
      JobSphereship.count.should == 1

      job_sphereship = JobSphereship.first
      job_sphereship.job_posting_id.should == @job_posting.id
      job_sphereship.job_sphere_id.should == @job_sphere.id
    end

  end

end
