class Api::SavingsEntriesController < Api::BaseApiController
  
  def index
    
    if params[:livesearch].present? 
      livesearch = "%#{params[:livesearch]}%"
      @objects = SavingsEntry.where{
        (
          (name =~  livesearch )
        )
        
      }.page(params[:page]).per(params[:limit]).order("id DESC")
      
      @total = SavingsEntry.where{ 
        (
          (name =~  livesearch )
        )
      }.count
      
      # calendar
      
    elsif params[:parent_id].present? and params[:is_savings_account].present?
      @objects = SavingsEntry.joins(:member).
                  where(
                    :member_id => params[:parent_id],
                    :savings_status => [
                              SAVINGS_STATUS[:savings_account],
                              SAVINGS_STATUS[:membership],
                              SAVINGS_STATUS[:locked] ]).
                  page(params[:page]).per(params[:limit]).order("id DESC")
      @total = SavingsEntry.where(            
                  :member_id => params[:parent_id],
                  :savings_status => [
                            SAVINGS_STATUS[:savings_account],
                            SAVINGS_STATUS[:membership],
                            SAVINGS_STATUS[:locked] ]).count 
    
    end
    
    # render :json => { :savings_entries => @objects , :total => @total , :success => true }
  end
  

  def create
    @object = SavingsEntry.create_object( params[:savings_entry] )
    params[:savings_entry][:confirmed_at] =  parse_date( params[:savings_entry][:confirmed_at] )
    if @object.errors.size == 0 
      render :json => { :success => true, 
                        :savings_entries => [@object] , 
                        :total => SavingsEntry.count }  
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
    @object = SavingsEntry.find(params[:id])
    params[:savings_entry][:confirmed_at] =  parse_date( params[:savings_entry][:confirmed_at] )
    
    if params[:confirm].present?  
      
      if not current_user.has_role?( :savings_entries, :confirm)
        render :json => {:success => false, :access_denied => "Tidak punya authorisasi"}
        return
      end
      
      
      begin
        ActiveRecord::Base.transaction do 
          @object.confirm(:confirmed_at => params[:savings_entry][:confirmed_at] )
        end
      rescue ActiveRecord::ActiveRecordError  
      else
      end
      
      
      
    elsif params[:unconfirm].present?
      
      if not current_user.has_role?( :savings_entries, :unconfirm)
        render :json => {:success => false, :access_denied => "Tidak punya authorisasi"}
        return
      end
      
      
      begin
        ActiveRecord::Base.transaction do 
          @object.unconfirm 
        end
      rescue ActiveRecord::ActiveRecordError  
      else
      end
      
      
      
    else
      @object.update_object( params[:savings_entry] )
    end
      
    
    
     direction_text = ""
    if @object.direction == FUND_TRANSFER_DIRECTION[:incoming] 
  		direction_text		=		"Penambahan" 
  	elsif @object.direction == FUND_TRANSFER_DIRECTION[:outgoing]
  		direction_text		=		"Penarikan" 
  	end
    
    if @object.errors.size == 0 
      render :json => { :success => true,   
                        :savings_entries =>[{
                          
                          :id 							=>  	@object.id                  ,
                        	:member_id 		    =>	  @object.member.id           ,
                        	:member_name 		  =>	  @object.member.name         ,
                        	:member_id_number =>	  @object.member.id_number    ,
                        	:direction 				=>		@object.direction           ,
                          :direction_text   =>    direction_text              ,
                        	:amount       => @object.amount,
                        	:is_confirmed => @object.is_confirmed,
                        	:confirmed_at => format_datetime_friendly( @object.confirmed_at ) 
                        	
                        	 
                        }],
                        :total => SavingsEntry.count  } 
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
    @object = SavingsEntry.find(params[:id])
    @object.delete_object 

    if  not @object.persisted?   
      render :json => { :success => true, :total => SavingsEntry.count }  
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
  
  
  # def confirm
  #   @object = SavingsEntry.find_by_id params[:id]
  #   # add some defensive programming.. current user has role admin, and current_user is indeed belongs to the company 
  #   
  #   begin
  #     ActiveRecord::Base.transaction do 
  #       @object.confirm(:confirmed_at => DateTime.now )
  #     end
  #   rescue ActiveRecord::ActiveRecordError  
  #   else
  #   end
  #   
  #   
  #   
  #   if @object.errors.size == 0  and @object.is_confirmed? 
  #     render :json => { :success => true, :total => SavingsEntry.count }  
  #   else
  #     # render :json => { :success => false, :total => Delivery.active_objects.count } 
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
      @objects = SavingsEntry.where{ (week_number =~ query)    
                              }.
                        page(params[:page]).
                        per(params[:limit]).
                        order("id DESC")
                        
      @total = SavingsEntry.where{ (week_number =~ query)   
                              }.count
    else
      @objects = SavingsEntry.where{ (id.eq selected_id)  
                              }.
                        page(params[:page]).
                        per(params[:limit]).
                        order("id ASC")
   
      @total = SavingsEntry.where{ (id.eq selected_id)  
                              }.count 
    end
    
    
    # render :json => { :records => @objects , :total => @total, :success => true }
  end
end
