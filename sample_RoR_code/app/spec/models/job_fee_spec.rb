require 'spec_helper'

describe JobFee do

  context 'fields' do
    it { should have_db_column(:number_of_months).of_type(:integer) }
    it { should have_db_column(:fee).of_type(:decimal).with_options(:precision => 10, :scale => 2) }
  end

  context 'mass assignment' do
    it { should_not allow_mass_assignment_of(:id) }
    it { should allow_mass_assignment_of(:number_of_months) }
    it { should allow_mass_assignment_of(:fee) }
    it { should_not allow_mass_assignment_of(:created_at) }
    it { should_not allow_mass_assignment_of(:updated_at) }
  end

  before(:each) do
    @job_fee = FactoryGirl.build(:job_fee_1)
    @job_fee_2 = FactoryGirl.build(:job_fee_2, id: 2)
  end

  context 'validations' do

    it 'should be valid' do
      @job_fee.should be_valid
    end

    it 'should not be valid without number of months' do
      @job_fee.number_of_months = nil
      @job_fee.should_not be_valid
    end

    it 'should not be valid without a fee' do
      @job_fee.fee = nil
      @job_fee.should_not be_valid
    end

  end

  context 'methods' do

    it 'should show valid job fee title' do
      @job_fee.save!
      @job_fee.title.should == "<span class='price'>$100</span><span class='months'>1 month</span>"

      @job_fee.number_of_months = 2
      @job_fee.save!
      @job_fee.title.should == "<span class='price'>$100</span><span class='months'>2 months</span>"
    end

    it 'should generate valid job fee options' do
      @job_fee.save!
      @job_fee_2.save!

      job_options = JobFee.job_fee_options

      job_options[0][0].should == "<span class='price'>$100</span><span class='months'>1 month</span>"
      job_options[1][0].should == "<span class='price'>$200</span><span class='months'>2 months</span>"
    end

  end

end