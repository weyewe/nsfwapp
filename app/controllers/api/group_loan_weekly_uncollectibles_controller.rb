class Api::GroupLoanWeeklyUncollectiblesController < Api::BaseApiController
  
  def index
    
    if params[:livesearch].present? 
      livesearch = "%#{params[:livesearch]}%"
      @objects = GroupLoanWeeklyUncollectible.where{
        (
          (name =~  livesearch )
        )
        
      }.page(params[:page]).per(params[:limit]).order("id DESC")
      
      @total = GroupLoanWeeklyUncollectible.where{ 
        (
          (name =~  livesearch )
        )
      }.count
      
      # calendar
      
    elsif params[:parent_id].present?
      @objects = GroupLoanWeeklyUncollectible.joins(:group_loan_weekly_collection, :group_loan_membership).
                  where(:group_loan_id => params[:parent_id]).
                  page(params[:page]).per(params[:limit]).order("id ASC")
      @total = GroupLoanWeeklyUncollectible.where(:group_loan_id => params[:parent_id]).count 
    else
      @objects = []
      @total = 0 
    end
    
    # render :json => { :group_loan_weekly_uncollectibles => @objects , :total => @total , :success => true }
  end
  

  def create
    @object = GroupLoanWeeklyUncollectible.create_object( params[:group_loan_weekly_uncollectible] )
    if @object.errors.size == 0 
      render :json => { :success => true, 
                        :group_loan_weekly_uncollectibles => [@object] , 
                        :total => GroupLoanWeeklyUncollectible.count }  
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
    @object = GroupLoanWeeklyUncollectible.find(params[:id])
    
    
    params[:group_loan_weekly_uncollectible][:collected_at] =  parse_date( params[:group_loan_weekly_uncollectible][:collected_at] ) 
    params[:group_loan_weekly_uncollectible][:cleared_at] =  parse_date( params[:group_loan_weekly_uncollectible][:cleared_at] ) 

    if params[:collect].present?  
      
      if not current_user.has_role?( :group_loan_weekly_uncollectibles, :collect)
        render :json => {:success => false, :access_denied => "Tidak punya authorisasi"}
        return
      end
      
      @object.collect(:collected_at => params[:group_loan_weekly_uncollectible][:collected_at] )
    elsif params[:clear].present?
      
      if not current_user.has_role?( :group_loan_weekly_uncollectibles, :clear)
        render :json => {:success => false, :access_denied => "Tidak punya authorisasi"}
        return
      end
      
      @object.clear( :cleared_at => params[:group_loan_weekly_uncollectible][:cleared_at] )
    else
      @object.update_object(params[:group_loan_weekly_uncollectible])
    end
    
    clearance_case_text = "" 
    if @object.clearance_case  ==  UNCOLLECTIBLE_CLEARANCE_CASE[:end_of_cycle]
  		clearance_case_text =  "Pemotongan Tabungan Wajib"
  	elsif  @object.clearance_case  ==  UNCOLLECTIBLE_CLEARANCE_CASE[:in_cycle]
  		clearance_case_text  = "Tunai"
  	end
  	
    if @object.errors.size == 0 
      render :json => { :success => true,   
                        :group_loan_weekly_uncollectibles => [
                          :id 			=>					@object.id ,
                        	:group_loan_weekly_collection_id 			 		=>				@object.group_loan_weekly_collection_id          ,
                        	:group_loan_weekly_collection_week_number =>		  	@object.group_loan_weekly_collection.week_number ,
                        	:group_loan_id 							              =>        @object.group_loan_id                            ,
                        	:group_loan_name 					                =>      	@object.group_loan.name                          ,
                        	:group_loan_membership_id			            =>        @object.group_loan_membership.id                 ,
                        	:group_loan_membership_member_name 		    =>      	@object.group_loan_membership.member.name        ,
                        	:group_loan_membership_member_id_number 	=>		    @object.group_loan_membership.member.id_number   ,
                        	:group_loan_membership_member_address 		=>	      @object.group_loan_membership.member.address     ,
                        	:amount 							                    =>        @object.amount                                   ,
                        	:principal						                    =>        @object.principal                                ,
                        	:is_collected					                    =>         @object.is_collected  ,
                        	:collected_at					                    =>        format_date_friendly(@object.collected_at  )     ,
                        	:is_cleared						                    =>        @object.is_cleared                               ,
                        	:cleared_at						                    =>        format_date_friendly( @object.cleared_at   )   ,
                        	:clearance_case                           =>        @object.clearance_case                           ,
                          :clearance_case_text => clearance_case_text
                        	
                          
                          ],
                        :total => GroupLoanWeeklyUncollectible.count  } 
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
    @object = GroupLoanWeeklyUncollectible.find(params[:id])
    @object.delete_object 

    if  not @object.persisted?   
      render :json => { :success => true, :total => GroupLoanWeeklyUncollectible.count }  
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
      @objects = GroupLoanWeeklyUncollectible.where{ (week_number =~ query)    
                              }.
                        page(params[:page]).
                        per(params[:limit]).
                        order("id DESC")
                        
      @total = GroupLoanWeeklyUncollectible.where{ (week_number =~ query)   
                              }.count
    else
      @objects = GroupLoanWeeklyUncollectible.where{ (id.eq selected_id)  
                              }.
                        page(params[:page]).
                        per(params[:limit]).
                        order("id ASC")
   
      @total = GroupLoanWeeklyUncollectible.where{ (id.eq selected_id)  
                              }.count 
    end
    
    
    # render :json => { :records => @objects , :total => @total, :success => true }
  end
end
