require 'spec_helper'

describe JobRegistration do

  context 'fields' do
    it { should have_db_column(:account_id).of_type(:integer) }
    it { should have_db_column(:job_posting_id).of_type(:integer) }
    it { should have_db_column(:job_fee_id).of_type(:integer) }
    it { should have_db_column(:start_date) }
    it { should have_db_column(:end_date) }
  end

  context 'mass assignment' do
    it { should_not allow_mass_assignment_of(:id) }
    it { should_not allow_mass_assignment_of(:account_id) }
    it { should_not allow_mass_assignment_of(:job_posting_id) }
    it { should allow_mass_assignment_of(:job_fee_id) }
    it { should allow_mass_assignment_of(:start_date) }
    it { should allow_mass_assignment_of(:end_date) }
    it { should_not allow_mass_assignment_of(:created_at) }
    it { should_not allow_mass_assignment_of(:updated_at) }
  end

  context 'associations' do
    it { should belong_to(:account) }
    it { should belong_to(:job_posting) }
  end

  before(:each) do
    @job_posting = FactoryGirl.build(:job_posting)
    @job_registration = FactoryGirl.build(:job_registration)
  end

  after(:each) { Delorean.back_to_the_present }

  context 'validations' do
    it 'should be valid' do
      @job_registration.should be_valid
    end

    it 'should not be valid without an account' do
      @job_registration.account_id = nil
      @job_registration.should_not be_valid
    end

    it 'should not be valid without a job posting' do
      @job_registration.job_posting_id = nil
      @job_registration.should_not be_valid
    end

    it 'should not be valid without a job fee on update' do
      @job_registration.save!
      @job_registration.job_fee_id = nil
      @job_registration.should_not be_valid
    end

    it 'should not be valid without a start date on update' do
      @job_registration.save!
      @job_registration.start_date = nil
      @job_registration.should_not be_valid
    end

    it 'should not be valid if start date is in the past' do
      @job_registration.save!
      @job_registration.start_date = 2.days.ago
      @job_registration.should_not be_valid
    end
  end

  context 'statuses' do
    it 'should be in pending status if start date is in the future' do
      @job_posting.job_registration_id = 1
      @job_posting.status = 'complete'
      @job_posting.save!

      @job_registration.start_date = 2.days.from_now
      @job_registration.end_date = 1.week.from_now
      @job_registration.job_posting_id = @job_posting.id
      @job_registration.save!

      @job_registration.pending?.should be_true
      @job_registration.open?.should be_false
      @job_registration.closed?.should be_false
    end

    it 'should be in open status if current date is between start date and end date' do
      @job_posting.job_registration_id = 1
      @job_posting.status = 'complete'
      @job_posting.save!

      @job_registration.start_date = Time.zone.now
      @job_registration.end_date = 1.week.from_now
      @job_registration.job_posting_id = @job_posting.id
      @job_registration.save!

      Delorean.time_travel_to(2.days.from_now)

      @job_registration.open?.should be_true
      @job_registration.pending?.should be_false
      @job_registration.closed?.should be_false
    end

    it 'should be in closed status if current date is after end date' do
      @job_posting.job_registration_id = 1
      @job_posting.status = 'complete'
      @job_posting.save!

      @job_registration.start_date = Time.zone.now
      @job_registration.end_date = 1.week.from_now
      @job_registration.job_posting_id = @job_posting.id
      @job_registration.save!

      Delorean.time_travel_to(2.weeks.from_now)

      @job_registration.closed?.should be_true
      @job_registration.pending?.should be_false
      @job_registration.open?.should be_false
    end
  end

  context 'methods' do
    let(:user) { FactoryGirl.create(:user, :id => 1) }
    let(:job_fee_1) { FactoryGirl.build(:job_fee_1) }
    let(:job_fee_2) { FactoryGirl.build(:job_fee_2) }

    it 'should singularize job fee number of months' do
      job_fee_1.save!
      @job_registration.number_of_months.should == '1 month'
    end

    it 'should pluralize job fee number of months' do
      job_fee_2.save!
      @job_registration.number_of_months.should == '2 months'
    end

    it 'should find valid job posting fee' do
      job_fee_2.save!
      @job_registration.job_posting_fee.should == 200.to_money
    end

    it 'should calculate end date based on start date and number of months' do
      job_fee_2.save!
      @job_registration.calculate_end_date.to_date.should == (@job_registration.start_date + 2.months).to_date
    end

    it 'should be able to process job registration', :vcr do
      pending 'Having braintree issues - need to revisist later'
      user.save!
      job_fee_1.save!
      @job_posting.save!
      user.account.balance.cents.should == 0

      @job_registration.job_posting_id = @job_posting.id
      @job_registration.account_id = user.account.id
      @job_registration.job_fee_id = job_fee_1.id
      @job_registration.end_date = @job_registration.calculate_end_date
      @job_registration.save!

      ap @job_registration
      ap @job_registration.job_posting_fee
      result = Braintree::Transaction.expects(:sale).returns(BraintreeFactory.successful_result("100.00"))
      ap result
    end
  end

  context 'build' do
    let(:user) { FactoryGirl.create(:user, :id => 1) }

    it 'job registration' do
      @job_posting.save!

      job_registration = JobRegistration.find_or_create_job_registration(user, @job_posting.id, 1)
      job_registration.account_id.should == user.account.id
      job_registration.job_posting_id.should == @job_posting.id
    end

  end
end

