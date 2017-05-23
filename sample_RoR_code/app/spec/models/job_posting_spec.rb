require 'spec_helper'

describe JobPosting do

  context 'fields' do
    it { should have_db_column(:employer_id).of_type(:integer) }
    it { should have_db_column(:job_registration_id).of_type(:integer) }
    it { should have_db_column(:status).of_type(:string) }
    it { should have_db_column(:title).of_type(:string) }
    it { should have_db_column(:job_location).of_type(:string) }
    it { should have_db_column(:latitude).of_type(:float) }
    it { should have_db_column(:longitude).of_type(:float) }
    it { should have_db_column(:job_type).of_type(:string) }
    it { should have_db_column(:hours_per_week).of_type(:string) }
    it { should have_db_column(:job_category).of_type(:string) }
    it { should have_db_column(:job_description).of_type(:text) }
    it { should have_db_column(:job_requirements).of_type(:text) }
    it { should have_db_column(:job_nice_to_haves).of_type(:text) }
    it { should have_db_column(:church_name).of_type(:string) }
    it { should have_db_column(:church_url).of_type(:string) }
    it { should have_db_column(:reports_to).of_type(:string) }
  end

  context 'mass assignment' do
    it { should_not allow_mass_assignment_of(:id) }
    it { should allow_mass_assignment_of(:job_registration_id) }
    it { should allow_mass_assignment_of(:employer_id) }
    it { should_not allow_mass_assignment_of(:status) }
    it { should allow_mass_assignment_of(:title) }
    it { should allow_mass_assignment_of(:job_location) }
    it { should_not allow_mass_assignment_of(:latitude) }
    it { should_not allow_mass_assignment_of(:longitude) }
    it { should allow_mass_assignment_of(:job_type) }
    it { should allow_mass_assignment_of(:hours_per_week) }
    it { should allow_mass_assignment_of(:job_category) }
    it { should allow_mass_assignment_of(:job_description) }
    it { should allow_mass_assignment_of(:job_requirements) }
    it { should allow_mass_assignment_of(:job_nice_to_haves) }
    it { should allow_mass_assignment_of(:church_name) }
    it { should allow_mass_assignment_of(:church_url) }
    it { should allow_mass_assignment_of(:reports_to) }
    it { should_not allow_mass_assignment_of(:created_at) }
    it { should_not allow_mass_assignment_of(:updated_at) }
  end

  context 'associations' do
    it { should have_one(:job_registration) }
    it { should have_many(:job_sphereships).dependent(:destroy) }
    it { should have_many(:job_spheres).through(:job_sphereships) }
    it { should have_many(:job_interests) }
  end

  before(:each) do
    @job_posting = FactoryGirl.build(:job_posting)
  end

  after(:each) { Delorean.back_to_the_present }

  context 'validations' do
    it 'should be valid' do
      @job_posting.should be_valid
    end

    it 'should not be valid without a title' do
      @job_posting.title = ''
      @job_posting.should_not be_valid
    end
  end

  context "statuses" do
    let(:user) { FactoryGirl.build(:user, id: 1) }
    let(:account) { FactoryGirl.build(:account, id: 1, user_id: 1) }
    let(:user2) { FactoryGirl.build(:user, id: 2) }
    let(:account2) { FactoryGirl.build(:account, id: 2, user_id: 2) }
    let(:user3) { FactoryGirl.build(:user, id: 3) }
    let(:account3) { FactoryGirl.build(:account, id: 3, user_id: 3) }
    let(:job_registration) { FactoryGirl.build(:job_registration, id: 1, job_posting_id: 1, account_id: 1) }
    let(:job_registration2) { FactoryGirl.build(:job_registration, id: 2, job_posting_id: 2,  account_id: 2) }
    let(:job_registration3) { FactoryGirl.build(:job_registration, id: 3, job_posting_id: 3, account_id: 3) }
    let(:job_posting) { FactoryGirl.build(:job_posting, id: 1, employer_id: 1, job_registration_id: 1) }
    let(:job_posting2) { FactoryGirl.build(:job_posting, id: 2, employer_id: 2, job_registration_id: 2) }
    let(:job_posting3) { FactoryGirl.build(:job_posting, id: 3, employer_id: 3, job_registration_id: 3) }
    let(:job_fee_1) { FactoryGirl.build(:job_fee_1, id: 1) }

    it 'should show valid incomplete job status' do
      @job_posting.incomplete?.should be_false
      @job_posting.status = 'incomplete'
      @job_posting.incomplete?.should be_true
    end

    it 'should show valid complete job status' do
      @job_posting.complete?.should be_false
      @job_posting.status = 'complete'
      @job_posting.complete?.should be_true
    end

    it 'should update status to complete' do
      @job_posting.status = 'incomplete'
      @job_posting.incomplete?.should be_true
      @job_posting.update_status
      @job_posting.complete?.should be_true
    end

    it 'should be new if start date is 1 week or less old' do
      user
      account

      job_registration.start_date = Time.zone.now
      job_registration.save!

      job_posting.status = 'complete'
      job_posting.save!

      job_posting.new?.should be_true
    end

    it 'should not be new if start date over 1 week old' do
      user
      account

      job_registration.start_date = Time.zone.now
      job_registration.save!

      job_posting.status = 'complete'
      job_posting.save!

      Delorean.time_travel_to(2.weeks.from_now)

      job_posting.new?.should be_false
    end

    it 'should find incomplete job postings for an employer' do
      JobPosting.count.should == 0

      job_posting.status = 'incomplete'
      job_posting.save!
      job_posting2.status = 'incomplete'
      job_posting2.save!

      JobPosting.count.should == 2
      job_postings = JobPosting.incomplete_job_postings(user.id)
      job_postings.count.should == 1
      job_postings.first.employer_id.should == user.id
      job_postings.first.employer_id.should_not == user2.id
    end

    it 'should find pending job postings for an employer' do
      job_fee_1.save!

      JobPosting.count.should == 0

      job_posting.employer_id = 2
      job_posting.status = 'complete'
      job_posting.save!

      job_posting2.employer_id = 2
      job_posting2.status = 'complete'
      job_posting2.save!

      job_posting3.employer_id = 2
      job_posting3.status = 'complete'
      job_posting3.save!

      job_registration.start_date = Time.zone.now
      job_registration.end_date = job_registration.calculate_end_date
      job_registration.save!

      job_registration2.start_date = 1.week.from_now
      job_registration2.end_date = job_registration2.calculate_end_date
      job_registration2.save!

      job_registration3.start_date = 4.weeks.from_now
      job_registration3.end_date = job_registration2.calculate_end_date
      job_registration3.save!

      Delorean.time_travel_to(2.weeks.from_now)

      JobPosting.count.should == 3
      job_postings = JobPosting.pending_job_postings(user2.id)
      job_postings.count.should == 1
      job_postings.first.job_registration.id.should == job_registration3.id
    end

    it 'should find open job postings for an employer' do
      job_fee_1.save!

      JobPosting.count.should == 0

      job_posting.employer_id = 2
      job_posting.status = 'complete'
      job_posting.save!

      job_posting2.employer_id = 2
      job_posting2.status = 'complete'
      job_posting2.save!

      job_posting3.employer_id = 2
      job_posting3.status = 'complete'
      job_posting3.save!

      job_registration.start_date = Time.zone.now
      job_registration.end_date = 1.week.from_now
      job_registration.save!

      job_registration2.start_date = 1.week.from_now
      job_registration2.end_date = job_registration2.calculate_end_date
      job_registration2.save!

      job_registration3.start_date = 4.weeks.from_now
      job_registration3.end_date = job_registration2.calculate_end_date
      job_registration3.save!

      Delorean.time_travel_to(2.weeks.from_now)

      JobPosting.count.should == 3
      job_postings = JobPosting.open_job_postings(user2.id)

      job_postings.count.should == 1
      job_postings.first.job_registration.id.should == job_registration2.id
    end

    it 'should find closed job postings for an employer' do
      job_fee_1.save!

      JobPosting.count.should == 0

      job_posting.employer_id = 2
      job_posting.status = 'complete'
      job_posting.save!

      job_posting2.employer_id = 2
      job_posting2.status = 'complete'
      job_posting2.save!

      job_posting3.employer_id = 2
      job_posting3.status = 'complete'
      job_posting3.save!

      job_registration.start_date = Time.zone.now
      job_registration.end_date = 1.week.from_now
      job_registration.save!

      job_registration2.start_date = 1.week.from_now
      job_registration2.end_date = job_registration2.calculate_end_date
      job_registration2.save!

      job_registration3.start_date = 4.weeks.from_now
      job_registration3.end_date = job_registration2.calculate_end_date
      job_registration3.save!

      Delorean.time_travel_to(2.weeks.from_now)

      JobPosting.count.should == 3
      job_postings = JobPosting.closed_job_postings(user2.id)

      job_postings.count.should == 1
      job_postings.first.job_registration.id.should == job_registration.id
    end

    it 'should find new job postings that are 1 week or less old for an applicant ' do
      job_fee_1.save!

      JobPosting.count.should == 0

      job_posting.employer_id = 1
      job_posting.status = 'complete'
      job_posting.save!

      job_posting2.employer_id = 2
      job_posting2.status = 'complete'
      job_posting2.save!

      job_posting3.employer_id = 2
      job_posting3.status = 'complete'
      job_posting3.save!

      job_registration.start_date = Time.zone.now
      job_registration.end_date = 2.weeks.from_now
      job_registration.save!

      job_registration2.start_date = 1.week.from_now
      job_registration2.end_date = job_registration2.calculate_end_date
      job_registration2.save!

      job_registration3.start_date = 4.weeks.from_now
      job_registration3.end_date = job_registration2.calculate_end_date
      job_registration3.save!

      Delorean.time_travel_to(6.days.from_now)

      JobPosting.count.should == 3
      job_postings = JobPosting.new_job_postings(JobPosting.completed_job_postings(user2.id))

      job_postings.count.should == 1
      job_postings.first.job_registration.id.should == job_registration.id
    end

    it 'should find open job postings for an applicant over 1 week old' do
      job_fee_1.save!

      JobPosting.count.should == 0

      job_posting.employer_id = 1
      job_posting.status = 'complete'
      job_posting.save!

      job_posting2.employer_id = 1
      job_posting2.status = 'complete'
      job_posting2.save!

      job_posting3.employer_id = 1
      job_posting3.status = 'complete'
      job_posting3.save!

      job_registration.start_date = Time.zone.now
      job_registration.end_date = 3.weeks.from_now
      job_registration.save!

      job_registration2.start_date = 2.weeks.from_now
      job_registration2.end_date = job_registration2.calculate_end_date
      job_registration2.save!

      job_registration3.start_date = 4.weeks.from_now
      job_registration3.end_date = job_registration2.calculate_end_date
      job_registration3.save!

      Delorean.time_travel_to(7.days.from_now)

      JobPosting.count.should == 3
      job_postings = JobPosting.available_job_postings(JobPosting.completed_job_postings(user2.id))

      job_postings.count.should == 1
      job_postings.first.job_registration.id.should == job_registration.id
    end
  end

  context "ownership" do
    let(:user) { FactoryGirl.create(:user, :id => 1) }
    let(:account) { FactoryGirl.build(:account, id: 1, user_id: 1) }
    let(:job_registration) { FactoryGirl.build(:job_registration, id: 1, account_id: 1) }
    let(:job_posting) { FactoryGirl.build(:job_posting, id: 1, employer_id: 1, job_registration_id: 1) }
    let(:job_sphere) { FactoryGirl.build(:job_sphere, id: 1, name: 'Business') }

    it 'should be owner if user is the employer' do
      user
      @job_posting.employer_id = user.id
      @job_posting.save!
      @job_posting.is_owner?(user.id).should be_true
    end

    it 'should not be owner if user is not the employer' do
      user
      @job_posting.employer_id = user.id + 1
      @job_posting.save!
      @job_posting.is_owner?(user.id).should be_false
    end

  end

  context "duplicate" do
    let(:user) { FactoryGirl.create(:user, :id => 1) }
    let(:job_posting) { FactoryGirl.build(:job_posting, id: 1, employer_id: 1, job_registration_id: 1) }
    let(:job_sphere) { FactoryGirl.build(:job_sphere, id: 1, name: 'Business') }

    it 'should be able to duplicate a job posting' do
      user
      job_posting.status = 'complete'
      job_posting.title = 'Duplicate Title'
      job_posting.job_location = 'Somewhere'
      job_posting.job_type = 'Full-time'
      job_posting.hours_per_week = '40'
      job_posting.job_description = 'A duplicate job'
      job_posting.job_requirements = 'Being able to duplicate'
      job_posting.job_nice_to_haves = 'Loving duplication'
      job_posting.church_name = 'The One Church'
      job_posting.church_url = 'http://onechurch.com'
      job_posting.reports_to = 'Duplicate Senior Pastor'
      job_posting.save!
      job_posting.job_spheres << job_sphere
      JobPosting.duplicate(user.id).should be_true
      duplicate_job_posting = JobPosting.where('status = ?', 'incomplete').first

      duplicate_job_posting.id.should_not == job_posting.id
      duplicate_job_posting.status.should_not == job_posting.status
      duplicate_job_posting.status.should == 'incomplete'
      duplicate_job_posting.title.should == job_posting.title
      duplicate_job_posting.job_registration.should == nil
      duplicate_job_posting.job_location.should == job_posting.job_location
      duplicate_job_posting.job_type.should == job_posting.job_type
      duplicate_job_posting.hours_per_week.should == job_posting.hours_per_week
      duplicate_job_posting.job_description.should == job_posting.job_description
      duplicate_job_posting.job_requirements.should == job_posting.job_requirements
      duplicate_job_posting.job_nice_to_haves.should == job_posting.job_nice_to_haves
      duplicate_job_posting.church_name.should == job_posting.church_name
      duplicate_job_posting.church_url.should == job_posting.church_url
      duplicate_job_posting.reports_to.should == job_posting.reports_to
      duplicate_job_posting.job_spheres[0].should == job_posting.job_spheres[0]
    end

  end

  context "job interest" do
    let(:employer) { FactoryGirl.create(:user, id: 1) }
    let(:job_posting) { FactoryGirl.build(:job_posting, id: 1, employer_id: 1, job_registration_id: 1, status: 'complete') }
    let(:applicant) { FactoryGirl.create(:user, id: 2) }
    let(:job_interest) { FactoryGirl.build(:job_interest, id: 1, applicant_id: 2) }
    let(:applicant2) { FactoryGirl.create(:user, id: 3) }
    let(:job_interest2) { FactoryGirl.build(:job_interest, id: 2, applicant_id: 3) }

    it 'should be false if job posting has no job interests' do
      job_posting.job_interests.count.should == 0
      job_posting.job_interest?(applicant.id).should be_false
    end

    it 'should be false if applicant has not expressed interest in job posting' do
      job_posting.save!
      job_posting.job_interests << job_interest2
      job_posting.job_interests.count.should == 1
      job_posting.job_interest?(applicant.id).should be_false
    end

    it 'should be true if applicant has expressed interest in job posting' do
      job_posting.save!
      job_posting.job_interests << job_interest
      job_posting.job_interests.count.should == 1
      job_posting.job_interest?(applicant.id).should be_true
    end
  end

  context 'user type' do
    let(:job_posting) { FactoryGirl.build(:job_posting, id: 1) }

    it 'should be applicant if param is set to job_interest' do
      params = { job_interest: 'job_interest' }
      job_posting.is_applicant?(params).should be_true
      job_posting.is_employer?(params).should be_false
    end

    it 'should be employer if param is set to employer' do
      params = { employer: 'employer' }
      job_posting.is_employer?(params).should be_true
      job_posting.is_applicant?(params).should be_false
    end

  end

  context 'expiration' do
    let(:job_registration) { FactoryGirl.build(:job_registration, id: 1, job_posting_id: 1) }
    let(:job_posting) { FactoryGirl.build(:job_posting, id: 1, job_registration_id: 1, status: 'complete') }
    let(:job_fee_1) { FactoryGirl.build(:job_fee_1, id: 1) }

    it 'job posting is about to expire if end date is 1 week in the future' do
      job_fee_1.save!

      JobPosting.count.should == 0

      job_posting.save!

      job_registration.start_date = Time.zone.now
      job_registration.end_date = 2.weeks.from_now
      job_registration.save!

      JobPosting.count.should == 1

      Delorean.time_travel_to(8.days.from_now)

      job_posting_ids = JobPosting.expired
      job_posting_ids.count.should == 0

      Delorean.back_to_the_present
      Delorean.time_travel_to(1.week.from_now)

      job_posting_ids = JobPosting.about_to_expire
      job_posting_ids.count.should == 1
      JobPosting.find_by_id(job_posting_ids.first).job_registration.id.should == job_registration.id

      Delorean.back_to_the_present
      Delorean.time_travel_to(6.days.from_now)

      job_posting_ids = JobPosting.expired
      job_posting_ids.count.should == 0
    end

    it 'job posting has expired if end date is 1 day in the past' do
      job_fee_1.save!

      JobPosting.count.should == 0

      job_posting.save!

      job_registration.start_date = Time.zone.now
      job_registration.end_date = 2.weeks.from_now
      job_registration.save!

      JobPosting.count.should == 1

      Delorean.time_travel_to(14.days.from_now)

      job_posting_ids = JobPosting.expired
      job_posting_ids.count.should == 0

      Delorean.back_to_the_present
      Delorean.time_travel_to(15.days.from_now)

      job_posting_ids = JobPosting.expired
      job_posting_ids.count.should == 1
      JobPosting.find_by_id(job_posting_ids.first).job_registration.id.should == job_registration.id

      Delorean.back_to_the_present
      Delorean.time_travel_to(16.days.from_now)

      job_posting_ids = JobPosting.expired
      job_posting_ids.count.should == 0
    end
  end

end