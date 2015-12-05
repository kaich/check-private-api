class CheckApiController < ApplicationController

  def new
    @user = User.new
  end

  def create
    @user = User.find_by(name:user_params[:name])
    if @user
      redirect_to edit_check_api_path(@user)
    else
      @user = User.new(user_params)
      generate_token
      
      respond_to do |wants|
        if @user.save
          flash[:notice] = ' was successfully created.'
          wants.html { redirect_to(edit_check_api_path(@user)) }
          wants.xml { render :xml => @user, :status => :created, :location => @user }
          wants.json { render :json => @user }
        else
          wants.html { render :action => "new" }
          wants.xml { render :xml => @user.errors, :status => :unprocessable_entity }
          wants.json { render :json => @user.errors }
        end
      end
    end
  end


  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    
  
    respond_to do |format|
      if @user.update(user_params)
        flash[:notice] = ' was successfully updated.'
        format.html { redirect_to(edit_check_api_path(@user)) }
        format.xml  { head :ok }
      else
        format.html { render action: 'edit' }
        format.xml  { render xml: @user.errors, status: :unprocessable_entity }
      end
    end
  end


  def show
    @user = User.find(params[:id])
  
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render xml: @user }
      format.json { render json: @user }
    end
  end
  
  def api_info
    @user = User.find_by(name:params[:name])
  
    respond_to do |format|
      format.json { render json: @user }
    end
  end


 private
  def user_params
      params.require(:user).permit(:name , :class_path , :class_name, :init_method, :call_methods)
  end

  def generate_token
    @user.token = loop do
      random_token = SecureRandom.urlsafe_base64(nil, false)
      break random_token unless User.exists?(token: random_token)
    end
  end
  
end
