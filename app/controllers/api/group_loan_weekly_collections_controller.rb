class Api::GroupLoanWeeklyCollectionsController < Api::BaseApiController
  
  def index
    
    if params[:livesearch].present? 
      livesearch = "%#{params[:livesearch]}%"
      @objects = GroupLoanWeeklyCollection.where{
        (
          (name =~  livesearch )
        )
        
      }.page(params[:page]).per(params[:limit]).order("id DESC")
      
      @total = GroupLoanWeeklyCollection.where{ 
        (
          (name =~  livesearch )
        )
      }.count
      
      # calendar
      
    elsif params[:parent_id].present?
      @objects = GroupLoanWeeklyCollection. 
                  where(:group_loan_id => params[:parent_id]).
                  page(params[:page]).per(params[:limit]).order("id ASC")
      @total = GroupLoanWeeklyCollection.where(:group_loan_id => params[:parent_id]).count 
    else
      @objects = []
      @total = 0 
    end
    
    # render :json => { :group_loan_weekly_collections => @objects , :total => @total , :success => true }
  end
  

  def create
    @object = GroupLoanWeeklyCollection.create_object( params[:group_loan_weekly_collection] )
    if @object.errors.size == 0 
      render :json => { :success => true, 
                        :group_loan_weekly_collections => [@object] , 
                        :total => GroupLoanWeeklyCollection.count }  
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
    @object = GroupLoanWeeklyCollection.find(params[:id])
    
    
    params[:group_loan_weekly_collection][:collected_at] =  parse_date( params[:group_loan_weekly_collection][:collected_at] ) 
    params[:group_loan_weekly_collection][:confirmed_at] =  parse_date( params[:group_loan_weekly_collection][:confirmed_at] ) 

    if params[:collect].present?  
      if not current_user.has_role?( :group_loan_weekly_collections, :collect)
        render :json => {:success => false, :access_denied => "Tidak punya authorisasi"}
        return
      end
      
      begin
        ActiveRecord::Base.transaction do 
          @object.collect(:collected_at => params[:group_loan_weekly_collection][:collected_at] )
        end
      rescue ActiveRecord::ActiveRecordError  
      else
      end
      
      
      
    elsif params[:uncollect].present?
      
      if not current_user.has_role?( :group_loan_weekly_collections, :uncollect)
        render :json => {:success => false, :access_denied => "Tidak punya authorisasi"}
        return
      end
      
      begin
        ActiveRecord::Base.transaction do 
          @object.uncollect 
        end
      rescue ActiveRecord::ActiveRecordError  
      else
      end
      
      
      
    elsif params[:confirm].present?
      
      if not current_user.has_role?( :group_loan_weekly_collections, :confirm)
        render :json => {:success => false, :access_denied => "Tidak punya authorisasi"}
        return
      end
      
      begin
        ActiveRecord::Base.transaction do 
          @object.confirm( :confirmed_at => params[:group_loan_weekly_collection][:confirmed_at] )
        end
      rescue ActiveRecord::ActiveRecordError  
      else
      end
      
      
      
    elsif params[:unconfirm].present?
      
      if not current_user.has_role?( :group_loan_weekly_collections, :unconfirm)
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
      @object.update_object(params[:group_loan_weekly_collection])
    end
    
    # @object.update_object( params[:group_loan] )
    if @object.errors.size == 0 
      render :json => { :success => true,   
                        :group_loan_weekly_collections => [
                            :id 							=>  	@object.id                  ,
                          	:group_loan_id 			=>     @object.group_loan_id   ,
                          	:group_loan_name 		=> 	  @object.group_loan.name  ,
                          	:week_number 				=> 	  @object.week_number      ,
                          	:is_collected			  =>   	@object.is_collected     ,
                          	:is_confirmed		    =>   	@object.is_confirmed     ,
                          	:collected_at       =>   	format_date_friendly( @object.collected_at )   ,
                          	:confirmed_at       =>     format_date_friendly( @object.confirmed_at )  ,
                          	:group_loan_weekly_uncollectible_count 				=> @object.group_loan_weekly_uncollectible_count,
                          	:group_loan_deceased_clearance_count 					=> @object.group_loan_deceased_clearance_count  ,
                          	:group_loan_run_away_receivable_count 				=> @object.group_loan_run_away_receivable_count ,
                          	:group_loan_premature_clearance_payment_count => @object.group_loan_premature_clearance_payment_count,
                          	:amount_receivable => @object.amount_receivable 
                          	 
                          ],
                        :total => GroupLoanWeeklyCollection.count  } 
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
    @object = GroupLoanWeeklyCollection.find_by_id params[:id] 
    render :json => { :success => true, 
                      :group_loan_weekly_collections => [
                          :id 							=>  	@object.id                  ,
                        	:group_loan_id 			=>     @object.group_loan_id   ,
                        	:group_loan_name 		=> 	  @object.group_loan.name  ,
                        	:week_number 				=> 	  @object.week_number      ,
                        	:is_collected			  =>   	@object.is_collected     ,
                        	:is_confirmed		    =>   	@object.is_confirmed     ,
                        	:collected_at       =>   	format_date_friendly( @object.collected_at )   ,
                        	:confirmed_at       =>     format_date_friendly( @object.confirmed_at )  ,
                        	:group_loan_weekly_uncollectible_count 				=> @object.group_loan_weekly_uncollectible_count,
                        	:group_loan_deceased_clearance_count 					=> @object.group_loan_deceased_clearance_count  ,
                        	:group_loan_run_away_receivable_count 				=> @object.group_loan_run_away_receivable_count ,
                        	:group_loan_premature_clearance_payment_count => @object.group_loan_premature_clearance_payment_count,
                        	:amount_receivable => @object.amount_receivable
                        	
                        	
                        ] , 
                      :total => GroupLoanWeeklyCollection.count }
  end

  # def destroy
  #   @object = GroupLoanWeeklyCollectionVoluntarySavingsEntry.find(params[:id])
  #   @parent_object = @object.group_loan_weekly_collection
  #   @object.delete_object 
  #   
  #   if ( not @object.persisted?  or @object.is_deleted ) and @object.errors.size == 0 
  #     render :json => { :success => true, :total => parent_object.group_loan_weekly_collection_voluntary_savings_entries.count }  
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
  
  def active_group_loan_memberships
    
     
      weekly_collection = GroupLoanWeeklyCollection.find(params[:group_loan_weekly_collection_id])
      @objects = weekly_collection.active_group_loan_memberships.joins(:member).
                order("id ASC")
    
    
    
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
      @objects = GroupLoanWeeklyCollection.where(:group_loan_id => params[:parent_id]).
                        page(params[:page]).
                        per(params[:limit]).
                        order("id DESC")
                        
      @total = GroupLoanWeeklyCollection.where(:group_loan_id =>  params[:parent_id]) .count
    else
      @objects = GroupLoanWeeklyCollection.where{ (id.eq selected_id)  
                              }.
                        page(params[:page]).
                        per(params[:limit]).
                        order("id ASC")
   
      @total = GroupLoanWeeklyCollection.where{ (id.eq selected_id)  
                              }.count 
    end
    
    
    # render :json => { :records => @objects , :total => @total, :success => true }
  end
end
