class Api::BranchesController < Api::BaseApiController
  
  def index
     
    
    if params[:livesearch].present? 
      livesearch = "%#{params[:livesearch]}%"
        
        
        @objects = Branch.where{
          (
            (name =~  livesearch ) | 
            (description =~ livesearch) | 
            (address =~ livesearch) | 
            (code =~ livesearch) 
          )

        }.page(params[:page]).per(params[:limit]).order("id DESC")

        @total = Branch.where{
          (
            (name =~  livesearch ) | 
            (description =~ livesearch) | 
            (address =~ livesearch) | 
            (code =~ livesearch) 
          )
        }.count
   
    else
      puts "In this shite"
      @objects = Branch.page(params[:page]).per(params[:limit]).order("id DESC")
      @total = Branch.count 
    end
    
    
    # render :json => { :branches => @objects , :total => @total , :success => true }
  end

  def create
    @object = Branch.create_object( params[:branch] )
    if @object.errors.size == 0 
      render :json => { :success => true, 
                        :branches => [
                          
                            :id               =>    @object.id                  ,
                            :name       =>     @object.name   ,
                            :description    =>    @object.description  ,
                            :address        =>    @object.address      ,
                            :code        =>    @object.code     
                          ] , 
                        :total => Branch.active_objects.count }  
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
    @object = Branch.find(params[:id]) 
    

    @object.update_object( params[:branch] )
    
     
    if @object.errors.size == 0 
      render :json => { :success => true,   
                        :branches => [
                          
                          :id               =>    @object.id                  ,
                          :name       =>     @object.name   ,
                          :description    =>    @object.description  ,
                          :address        =>    @object.address      ,
                          :code        =>    @object.code     
                          
                        ],
                        :total => Branch.active_objects.count  } 
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
  
  def show
    @object = Branch.find_by_id params[:id]
    render :json => { :success => true, 
                      :branches => [@object] , 
                      :total => Branch.count }
  end

  def destroy
    @object = Branch.find(params[:id])
    
    begin
      ActiveRecord::Base.transaction do 
        @object.delete_object 
      end
    rescue ActiveRecord::ActiveRecordError  
    else
    end
    
    

    if not @object.persisted?  
      render :json => { :success => true, :total => Branch.active_objects.count }  
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
  
  
  def search
    search_params = params[:query]
    selected_id = params[:selected_id]
    if params[:selected_id].nil?  or params[:selected_id].length == 0 
      selected_id = nil
    end
    
    query = "%#{search_params}%"
    # on PostGre SQL, it is ignoring lower case or upper case 
    
    if  selected_id.nil?
      @objects = Branch.where{ 

                           (
                              (name =~  query ) | 
                              (description =~ query) | 
                              (address =~ query) | 
                              (code =~ query) 
                            )
                              }.
                        page(params[:page]).
                        per(params[:limit]).
                        order("id DESC")
                        
      @total = Branch.where{ (name =~ query)  
                              }.count
    else
      @objects = Branch.where{ (id.eq selected_id)  
                              }.
                        page(params[:page]).
                        per(params[:limit]).
                        order("id DESC")
   
      @total = Branch.where{ (id.eq selected_id)   
                              }.count 
    end
    
    
    render :json => { :records => @objects , :total => @total, :success => true }
  end
end
