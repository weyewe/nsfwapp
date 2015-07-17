class Api::MemorialDetailsController < Api::BaseApiController
  
  def index
    @parent = Memorial.find_by_id params[:memorial_id]
    @objects = @parent.active_memorial_details.joins(:memorial, :account).page(params[:page]).per(params[:limit]).order("id DESC")
    @total = @parent.active_memorial_details.count
  end

  def create
   
    @parent = Memorial.find_by_id params[:memorial_id]
    
  
    @object = MemorialDetail.create_object(params[:memorial_detail])
    
    
    if @object.errors.size == 0 
      render :json => { :success => true, 
                        :memorial_details => [@object] , 
                        :total => @parent.active_memorial_details.count }  
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
    @object = MemorialDetail.find_by_id params[:id] 
    @parent = @object.memorial 
    
    
    params[:memorial_detail][:memorial_id] = @parent.id  
    
    @object.update_object( params[:memorial_detail])
     
    if @object.errors.size == 0 
      render :json => { :success => true,   
                        :memorial_details => [@object],
                        :total => @parent.active_memorial_details.count  } 
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
    @object = MemorialDetail.find(params[:id])
    @parent = @object.memorial 
    @object.delete_object 

    if  not @object.persisted? 
      render :json => { :success => true, :total => @parent.active_memorial_details.count }  
    else
      render :json => { :success => false, :total =>@parent.active_memorial_details.count ,
            :message => {
              :errors => extjs_error_format( @object.errors )  
            }
            }  
    end
  end
 
  
 
end
