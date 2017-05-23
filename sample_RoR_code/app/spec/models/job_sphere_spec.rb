require 'spec_helper'

describe JobSphere do

  context 'fields' do
    it { should have_db_column(:name).of_type(:string) }
  end

  context 'mass assignment' do
    it { should_not allow_mass_assignment_of(:id) }
    it { should allow_mass_assignment_of(:name) }
    it { should_not allow_mass_assignment_of(:created_at) }
    it { should_not allow_mass_assignment_of(:updated_at) }
  end

  before(:each) do
    @job_sphere = FactoryGirl.build(:job_sphere)
  end

  context 'validations' do
    let(:job_sphere) { FactoryGirl.build(:job_sphere, id: 1, name: 'Business') }
    let(:job_sphere2) { FactoryGirl.build(:job_sphere, id: 1, name: 'Business') }

    it 'should be valid' do
      @job_sphere.should be_valid
    end

    it 'should not be valid without name' do
      @job_sphere.name = nil
      @job_sphere.should_not be_valid
    end

    it 'should not be valid without unique name' do
      job_sphere.save!
      job_sphere.should be_valid
      job_sphere2.should_not be_valid
    end

  end

end