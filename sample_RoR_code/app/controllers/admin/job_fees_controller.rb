class Admin::JobFeesController < Admin::BaseController

  authorize_resource :class => "JobFee"

  # GET /admin/titles
  def index
    @job_fees = JobFee.all
  end

  # GET /admin/titles/1
  def show
    @job_fee = JobFee.find(params[:id])
  end

  # GET /admin/titles/new
  def new
    @job_fee = JobFee.new
  end

  # GET /admin/titles/1/edit
  def edit
    @job_fee = JobFee.find(params[:id])
  end

  # POST /titles
  def create
    @job_fee = JobFee.new(params[:job_fee])

    if @job_fee.save
      redirect_to(admin_job_fees_path, :notice => 'Job Fee was successfully created.')
    else
      render :action => "new"
    end
  end

  # PUT /titles/1
  def update
    @job_fee = JobFee.find(params[:id])

    if @job_fee.update_attributes(params[:job_fee])
      redirect_to(admin_job_fees_path, :notice => 'Job Fee was successfully updated.')
    else
      render :action => "edit"
    end
  end

  # DELETE /titles/1
  def destroy
    @job_fee = JobFee.find(params[:id])
    @job_fee.destroy

    redirect_to(admin_job_fees_path, :notice => 'Job Fee was successfully deleted.')
  end

end
