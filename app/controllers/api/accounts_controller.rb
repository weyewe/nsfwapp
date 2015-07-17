class Api::AccountsController < Api::BaseApiController
  
  def index
    
    if params[:livesearch].present? 
      livesearch = "%#{params[:livesearch]}%"
      @objects = Account.where{
        (is_deleted.eq false) & 
        (
          (name =~  livesearch ) | 
          (code =~ livesearch)
        )
        
      }.page(params[:page]).per(params[:limit]).order("id ASC")
      
      @total = Account.where{
        (is_deleted.eq false) & 
        (
          (name =~  livesearch ) | 
          (code =~ livesearch)
        )
      }.count
      
      # calendar
      
    else
      @objects = Account.active_accounts.where(:depth => 0).order("id ASC")
      @total = @objects.count 
    end
    
    
    # render :json => { :accounts => @objects , :total => @total , :success => true }
  end
  
  def show
    @object = Account.find_by_id params[:id]
    
    @parent = @object
    @objects = @object.children
    @total = @objects.count 
    
    # render :json => { :accounts => @objects , :total => @total , :success => true }
  end

  def create
 
      # @object = Account.new(params[:account])
 
    puts "\n\n============>"
    
    puts "The name is : #{params[:account][:name]}\n\n"
    @object = Account.create_object( params[:account]   )
    if @object.errors.size == 0 
      render :json => { :success => true, 
                        :accounts => [@object] , 
                        :total => Account.active_accounts.count }  
    else
      msg = {
        :success => false, 
        :message => {
          :errors => extjs_error_format( @object.errors ) 
          # :errors => {
          #   :name => "Nama tidak boleh bombastic"
          # }
        }
      }
      
      render :json => msg                         
    end
  end

  def update
    @object = Account.find(params[:id])
    
    
    # puts "\n\n============>"
    
    # puts "The name is : #{params[:account][:name]}\n\n"
    
    
    @object.update_object( params[:account]  )
    
    if @object.errors.size == 0 
      render :json => { :success => true,   
                        :accounts => [@object],
                        :total => Account.active_accounts.count  } 
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
    @object = Account.find(params[:id])
    @object.delete_object 

    if (not @object.persisted?) 
      render :json => { :success => true, :total => Account.active_accounts.count }  
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
  
  
  def search_ledger
    search_params = params[:query]
    selected_id = params[:selected_id]
    if params[:selected_id].nil?  or params[:selected_id].length == 0 
      selected_id = nil
    end
    
    query = "%#{search_params}%"
    # on PostGre SQL, it is ignoring lower case or upper case 
    
    if  selected_id.nil?
      @objects = Account.active_accounts.where{ 
                          (name =~ query)  & 
                          (account_case.eq ACCOUNT_CASE[:ledger])
        
                              }.
                        page(params[:page]).
                        per(params[:limit]).
                        order("id DESC")
                        
      @total =  Account.active_accounts.where{ (name =~ query)                   & 
                        (account_case.eq ACCOUNT_CASE[:ledger])  }.count
    else
      @objects = Account.active_accounts.where{ (id.eq selected_id)  & 
                                  (account_case.eq ACCOUNT_CASE[:ledger])
                              }.
                        page(params[:page]).
                        per(params[:limit]).
                        order("id DESC")
      @total =  Account.active_accounts.where{ (id.eq selected_id)                   & 
                        (account_case.eq ACCOUNT_CASE[:ledger])  }.count
    end
    
    
    # render :json => { :records => @objects , :total => @objects.count, :success => true }
  end
end
