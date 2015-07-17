class Api::AppUsersController < Api::BaseApiController
  
  def index
    
    if params[:livesearch].present? 
      livesearch = "%#{params[:livesearch]}%"
      @objects = User.where{
        (is_deleted.eq false) & 
        (
          (name =~  livesearch ) | 
          (email =~  livesearch )
        )
        
      }.page(params[:page]).per(params[:limit]).order("id DESC")
      
      @total = User.where{
        (is_deleted.eq false) & 
        (
          (name =~  livesearch ) | 
          (email =~  livesearch )
        )
        
      }.count
    else
      @objects = User.active_objects.page(params[:page]).per(params[:limit]).order("id DESC")
      @total = User.active_objects.count
    end
    
    
    
    # render :json => { :users => @objects , :total => @total, :success => true }
  end

  def create
    @object = User.create_object( params[:user] )  
    
    

 
    if @object.errors.size == 0 
      @object.device_id = params[:deviceToken]
      
      render :json => { :success => true, 
                        :users => [@object] , 
                        :total => User.active_objects.count }  
    else

      msg = {
        :success => false, 
        :message => {
          :errors => extjs_error_format( @object.errors )  
        }
      }
      
      render :json => msg                         
    end
  end

  def update
    
    @object = User.find_by_id params[:id] 
    @object.update_object( params[:user])
     
    if @object.errors.size == 0 
      render :json => { :success => true,   
                        :users => [@object],
                        :total => User.active_objects.count  } 
    else
      msg = {
        :success => false, 
        :message => {
          :errors => extjs_error_format( @object.errors )  
        }
      }
      
      render :json => msg 
    end
  end

  def destroy
    @object = User.find(params[:id])
    
    if not current_user.is_main_user?
      @object.errors.add(:generic_errors, "Delete hanya dapat dilakukan oleh user utama")
    end
    
    
    if @object.id == current_user.id
      @object.errors.add(:generic_errors, "Tidak dapat delete diri sendiri")
    end
    
    
    
    @object.delete_object

    if @object.is_deleted and @object.errors.size == 0 
      render :json => { :success => true, :total => User.active_objects.count }  
    else
      render :json => {
        :success => false, 
        :message => {
          :errors => extjs_error_format( @object.errors )  
        }
      }
    end
  end
  
  def search
    search_params = params[:query]
    selected_id = params[:selected_id]
    if params[:selected_id].nil?  or params[:selected_id].length == 0 
      selected_id = nil
    end
    
    query = "%#{search_params}%"
    # on PostGre SQL, it is ignoring lower case or upper case 
    
    if  selected_id.nil?
      @objects = User.where{ (name =~ query)   
                              }.
                        page(params[:page]).
                        per(params[:limit]).
                        order("id DESC")
                        
      @total = User.where{ (name =~ query)  
                              }.count
    else
      @objects = User.where{ (id.eq selected_id)  
                              }.
                        page(params[:page]).
                        per(params[:limit]).
                        order("id DESC")
   
      @total = User.where{ (id.eq selected_id)   
                              }.count 
    end
    
    
    render :json => { :records => @objects , :total => @total, :success => true }
  end
end
