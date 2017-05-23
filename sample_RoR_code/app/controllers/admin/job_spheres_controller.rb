class Admin::JobSpheresController < Admin::BaseController

  authorize_resource :class => "JobSphere"

  # GET /admin/titles
  def index
    @job_spheres = JobSphere.where("name like ?", "%#{params[:q]}%").order(sort_column + " " + sort_direction).page(params[:page])
  end

  # GET /admin/titles/1
  def show
    @job_sphere = JobSphere.find(params[:id])
  end

  # GET /admin/titles/new
  def new
    @job_sphere = JobSphere.new
  end

  # GET /admin/titles/1/edit
  def edit
    @job_sphere = JobSphere.find(params[:id])
  end

  # POST /titles
  def create
    @job_sphere = JobSphere.new(params[:job_sphere])

    if @job_sphere.save
      redirect_to(admin_job_spheres_path, :notice => 'Job Category was successfully created.')
    else
      render :action => "new"
    end
  end

  # PUT /titles/1
  def update
    @job_sphere = JobSphere.find(params[:id])

    if @job_sphere.update_attributes(params[:job_sphere])
      redirect_to(admin_job_spheres_path, :notice => 'Job Category was successfully updated.')
    else
      render :action => "edit"
    end
  end

  # DELETE /titles/1
  def destroy
    @job_sphere = JobSphere.find(params[:id])
    @job_sphere.destroy

    redirect_to(admin_job_spheres_path, :notice => 'Job Category was successfully deleted.')
  end

end
