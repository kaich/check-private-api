class ApiResultsController < ApplicationController

  protect_from_forgery unless: -> { request.format.json? }

  def index
    @user  = User.find_by(:name => session[:name])
    if @user
      @api_results = @user.api_results
    else
      flash[:alert] = "请重新提交用户名"
      redirect_to root_path
    end

  
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render xml: @model_class_napi_resultsmes }
    end
  end

  def new
    @api_result = ApiResult.new
  end

  def create
    @user  = User.find_by(:name => params[:name])
    @api_result = @user.api_results.build(result_params)

    respond_to do |wants|
      if @user.save
        flash[:notice] = ' was successfully created.'
        wants.html { redirect_to(@api_result) }
        wants.xml { render :xml => @api_result, :status => :created, :location => @api_result }
        wants.json { render :json => @api_result, :status => :created, :location => @api_result }
      else
        wants.html { render :action => "new" }
        wants.xml { render :xml => @api_result.errors, :status => :unprocessable_entity }
        wants.json { render :json => @api_result.errors, :status => :unprocessable_entity }
      end
    end
  end


  def show
    @api_result = ApiResult.find(params[:id]) 

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render xml: @api_result }
      format.json  { render json: @api_result }
    end
  end
  

  private 

  def result_params
    params.require(:api_result).permit(:title,:content)
  end

end
