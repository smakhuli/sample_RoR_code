
require 'api_constraints'

GlobalLegacy::Application.routes.draw do

  resources :job_postings do
    member do
      get :duplicate
      get :view_interests
    end
  end

  resources :job_registrations do
    member do
      get :job_confirm
      get :job_checkout
      get :job_charge_on_file
      get :job_receipt
    end
  end

  resources :job_interests do
    member do
      get :contacted
      get :hired
    end
  end
  match '/jobs', :controller => 'job_interests', :action => 'index'
  match '/postjob', :controller => 'job_postings', :action => 'index', :defaults => { :job_posting => "post a job" }

  # Namespace for Admin Section
  namespace :admin do

    resources :job_postings
    resources :job_interests
    resources :job_spheres
    resources :job_fees
    resources :job_listings

    resources :job_reports, :only => :index do
      collection do
        get :payment_forecast
        get :bank_recon
        get :registration_totals
        get :registration_stats
        get :registration_job_postings
        get :registration_stats_all_years
      end
    end
  end

end
