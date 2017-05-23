class Ability
  include CanCan::Ability

  # For Reference:
  #
  # https://github.com/ryanb/cancan/wiki/Action-Aliases
  # CanCan Abilities Action Aliases
  # alias_action :index, :show, :to => :read
  # alias_action :new, :to => :create
  # alias_action :edit, :to => :update
  #
  # List of roles from the User model:
  # ROLES = %w[superuser tech_manager deployment_manager ldp_manager executive gl_intern]

  def initialize(user)
    @user = user || User.new # for guest

    ######################################################################
    # GUEST - role is NULL ---> Guest, not logged in
    send(@user.role.to_sym)
    # END GUEST
    ######################################################################
  end


  ######################################################################
  # USER  ---> Someone has registered and is logged in
  def user
    # Manage the Job Posting they own
    can [:read, :create, :update, :destroy], JobPosting do |job_posting|
      job_posting.is_owner?(@user.id)
    end

    # Manage the Job Interest they own
    can [:read, :create, :update, :destroy], JobInterest do |job_interest|
      job_interest.is_owner?(@user.id)
    end
  end

  ######################################################################
  # tech_manager ---> Admin power permissions to edit content etc.
  def tech_manager
    user
    can :read, :job_reports
  end

end