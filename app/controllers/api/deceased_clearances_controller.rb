class Api::DeceasedClearancesController < Api::BaseApiController
  
  def index
    
    if params[:livesearch].present? 
      livesearch = "%#{params[:livesearch]}%"
      @objects = DeceasedClearance.where{
        (
          (name =~  livesearch )
        )
        
      }.page(params[:page]).per(params[:limit]).order("id DESC")
      
      @total = DeceasedClearance.where{ 
        (
          (name =~  livesearch )
        )
      }.count
      
      # calendar
      
    elsif params[:parent_id].present?
      @objects = DeceasedClearance.joins(:member).
                  where(:member_id => params[:parent_id]).
                  page(params[:page]).per(params[:limit]).order("id ASC")
      @total = DeceasedClearance.where(:member_id => params[:parent_id]).count 
   
    end
    
    # render :json => { :deceased_clearances => @objects , :total => @total , :success => true }
  end
  

  def create
    @object = DeceasedClearance.create_object( params[:deceased_clearance] )
    if @object.errors.size == 0 
      render :json => { :success => true, 
                        :deceased_clearances => [@object] , 
                        :total => DeceasedClearance.count }  
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
    @object = DeceasedClearance.find(params[:id])
    
    @object.update_object( params[:deceased_clearance] )
    if @object.errors.size == 0 
      render :json => { :success => true,   
                        :deceased_clearances => [@object],
                        :total => DeceasedClearance.count  } 
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

  # def destroy
  #   @object = DeceasedClearance.find(params[:id])
  #   @object.delete_object 
  # 
  #   if ( not @object.persisted?  or @object.is_deleted ) and @object.errors.size == 0 
  #     render :json => { :success => true, :total => DeceasedClearance.count }  
  #   else
  #     msg = {
  #       :success => false, 
  #       :message => {
  #         :errors => extjs_error_format( @object.errors )  
  #       }
  #     }
  #     
  #     render :json => msg
  #   end
  # end
  
  
  def search
    search_params = params[:query]
    selected_id = params[:selected_id]
    if params[:selected_id].nil?  or params[:selected_id].length == 0 
      selected_id = nil
    end
    
    query = "%#{search_params}%"
    # on PostGre SQL, it is ignoring lower case or upper case 
    
    if  selected_id.nil?
      @objects = DeceasedClearance.where{ (week_number =~ query)    
                              }.
                        page(params[:page]).
                        per(params[:limit]).
                        order("id DESC")
                        
      @total = DeceasedClearance.where{ (week_number =~ query)   
                              }.count
    else
      @objects = DeceasedClearance.where{ (id.eq selected_id)  
                              }.
                        page(params[:page]).
                        per(params[:limit]).
                        order("id ASC")
   
      @total = DeceasedClearance.where{ (id.eq selected_id)  
                              }.count 
    end
    
    
    # render :json => { :records => @objects , :total => @total, :success => true }
  end
end
