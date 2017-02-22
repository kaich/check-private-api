class CheckApiController < ApplicationController

  def index
    @api_results = ApiResult.where(user_name: params[:user_name])
  
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render xml: @api_resultss }
    end
  end

  def new
    @api_result = ApiResult.new
  end

  def create
    @api_result = ApiResult.new(api_params)
      
    respond_to do |wants|
      if @api_result.save
        flash[:notice] = ' was successfully created.'
        wants.html { redirect_to(edit_check_api_path(@api_result)) }
        wants.xml { render :xml => @api_result, :status => :created, :location => @api_result }
        wants.json { render :json => @api_result }
      else
        wants.html { render :action => "new" }
        wants.xml { render :xml => @api_result.errors, :status => :unprocessable_entity }
        wants.json { render :json => @api_result.errors }
      end
    end
  end


  def edit
    @api_result = ApiResult.find(params[:id])
  end

  def update
    @api_result = ApiResult.find(params[:id])
  
    respond_to do |format|
      if @api_result.update(api_params)
        flash[:notice] = ' was successfully updated.'
        format.html { redirect_to(edit_check_api_path(@api_result)) }
        format.xml  { head :ok }
      else
        format.html { render action: 'edit' }
        format.xml  { render xml: @api_result.errors, status: :unprocessable_entity }
      end
    end
  end

  def mobile_api_result
    @api_result = ApiResult.find(params[:id])
  
    respond_to do |format|
      if @api_result.update(mobile_api_params)
        format.json  { head :ok }
      else
        format.json  { render json: @api_result.errors, status: :unprocessable_entity }
      end
    end
  end


  def show
    @api_result = User.find(params[:id])
  
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render xml: @api_result }
      format.json { render json: @api_result }
    end
  end
  
  def api_info
    @api_result = ApiResult.where(user_name:params[:name]).order(created_at: :desc).first
  
    respond_to do |format|
      format.json { render json: @api_result }
    end
  end


 private
  def api_params
      params.require(:api_result).permit(:user_name , :class_path , :class_name, :init_method, :call_methods, :result)
  end

  def mobile_api_params
      params.require(:check_api)  
  end
  
end
