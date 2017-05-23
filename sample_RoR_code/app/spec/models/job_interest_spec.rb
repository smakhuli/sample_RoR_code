require 'spec_helper'

describe JobInterest do

  context 'fields' do
    it { should have_db_column(:job_posting_id).of_type(:integer) }
    it { should have_db_column(:applicant_id).of_type(:integer) }
    it { should have_db_column(:name).of_type(:string) }
    it { should have_db_column(:job_location).of_type(:string) }
    it { should have_db_column(:latitude).of_type(:float) }
    it { should have_db_column(:longitude).of_type(:float) }
    it { should have_db_column(:phone_number).of_type(:string) }
    it { should have_db_column(:email).of_type(:string) }
    it { should have_db_column(:why_me).of_type(:text) }
    it { should have_db_column(:start_date) }
    it { should have_db_column(:status).of_type(:string) }
  end

  context 'mass assignment' do
    it { should_not allow_mass_assignment_of(:id) }
    it { should allow_mass_assignment_of(:job_posting_id) }
    it { should allow_mass_assignment_of(:applicant_id) }
    it { should allow_mass_assignment_of(:name) }
    it { should_not allow_mass_assignment_of(:job_location) }
    it { should allow_mass_assignment_of(:phone_number) }
    it { should allow_mass_assignment_of(:email) }
    it { should allow_mass_assignment_of(:why_me) }
    it { should allow_mass_assignment_of(:start_date) }
    it { should_not allow_mass_assignment_of(:created_at) }
    it { should_not allow_mass_assignment_of(:updated_at) }
  end

  context 'associations' do
    it { should belong_to(:job_posting) }
  end

  before(:each) do
    @job_interest = FactoryGirl.build(:job_interest)
  end

  context 'validations' do

    it 'should be valid' do
      @job_interest.should be_valid
    end

    it 'should not be valid without a name' do
      @job_interest.name = ''
      @job_interest.should_not be_valid
    end

  end

  context 'status' do

    it 'should have status of interested' do
      @job_interest.status = 'interested'
      @job_interest.interested?.should be_true
      @job_interest.contacted?.should_not be_true
      @job_interest.hired?.should_not be_true
    end

    it 'should have status of contacted' do
      @job_interest.status = 'contacted'
      @job_interest.contacted?.should be_true
      @job_interest.interested?.should_not be_true
      @job_interest.hired?.should_not be_true
    end

    it 'should have status of hired' do
      @job_interest.status = 'hired'
      @job_interest.hired?.should be_true
      @job_interest.contacted?.should_not be_true
      @job_interest.interested?.should_not be_true
    end

  end

  context 'methods' do
    let(:user) { FactoryGirl.create(:user, :id => 1) }

    it 'should be owner if user is the applicant' do
      user
      @job_interest.applicant_id = user.id
      @job_interest.save!
      @job_interest.is_owner?(user.id).should be_true
    end

    it 'should not be owner if user is not the applicant' do
      user
      @job_interest.applicant_id = user.id + 1
      @job_interest.save!
      @job_interest.is_owner?(user.id).should be_false
    end

  end

end