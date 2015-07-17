class Api::GroupLoansController < Api::BaseApiController
  
  def index
    
    if params[:livesearch].present? 
      livesearch = "%#{params[:livesearch]}%"
      @objects = GroupLoan.includes(:group_loan_memberships).where{
        (
          (name =~  livesearch )  
        )
        
      }.page(params[:page]).per(params[:limit]).order("id DESC")
      
      @total = GroupLoan.where{
        (
          (name =~  livesearch )
        )
      }.count
      
      # calendar
      
      puts "TOtal @objects: #{@objects.count}"
      
    else
      @objects = GroupLoan.includes(:group_loan_memberships).page(params[:page]).per(params[:limit]).order("id DESC")
      @total = GroupLoan.count 
    end
    
    
    # render :json => { :group_loans => @objects , :total => @total , :success => true }
  end

  def create
    # @object = GroupLoan.new(params[:group_loan])
 
    @object = GroupLoan.create_object( params[:group_loan] )
    if @object.errors.size == 0 
      render :json => { :success => true, 
                        :group_loans => [@object] , 
                        :total => GroupLoan.count }  
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
    @object = GroupLoan.find(params[:id])
    
    
    params[:group_loan][:started_at] =  parse_date( params[:group_loan][:started_at] )
    params[:group_loan][:disbursed_at] =  parse_date( params[:group_loan][:disbursed_at] )
    params[:group_loan][:closed_at] =  parse_date( params[:group_loan][:closed_at] )
    params[:group_loan][:compulsory_savings_withdrawn_at] =  parse_date( params[:group_loan][:compulsory_savings_withdrawn_at] )

    if params[:start].present?  
      if not current_user.has_role?( :group_loans, :start)
        render :json => {:success => false, :access_denied => "Tidak punya authorisasi"}
        return
      end
      
      begin
        ActiveRecord::Base.transaction do 
          @object.start(:started_at => params[:group_loan][:started_at] )
        end
      rescue ActiveRecord::ActiveRecordError  
      else
      end
      
      
      
      
      
    elsif params[:unstart].present?    
      
      if not current_user.has_role?( :group_loans, :unstart)
        render :json => {:success => false, :access_denied => "Tidak punya authorisasi"}
        return
      end
      
      begin
        ActiveRecord::Base.transaction do 
          @object.cancel_start
        end
      rescue ActiveRecord::ActiveRecordError  
      else
      end
      
      
    elsif params[:disburse].present?
      if not current_user.has_role?( :group_loans, :disburse)
        render :json => {:success => false, :access_denied => "Tidak punya authorisasi"}
        return
      end
      
      
      begin
        ActiveRecord::Base.transaction do 
          @object.disburse_loan( :disbursed_at => params[:group_loan][:disbursed_at] )
        end
      rescue ActiveRecord::ActiveRecordError  
      else
      end
      
      
      
    elsif params[:undisburse].present?  
      if not current_user.has_role?( :group_loans, :undisburse)
        render :json => {:success => false, :access_denied => "Tidak punya authorisasi"}
        return
      end
      
      begin
        ActiveRecord::Base.transaction do 
          @object.undisburse
        end
      rescue ActiveRecord::ActiveRecordError  
      else
      end
      
    elsif params[:close].present?
      if not current_user.has_role?( :group_loans, :close)
        render :json => {:success => false, :access_denied => "Tidak punya authorisasi"}
        return
      end
      
      begin
        ActiveRecord::Base.transaction do 
          @object.close( :closed_at => params[:group_loan][:closed_at] )
        end
      rescue ActiveRecord::ActiveRecordError  
      else
      end
      
    elsif params[:withdraw].present?
      if not current_user.has_role?( :group_loans, :withdraw)
        render :json => {:success => false, :access_denied => "Tidak punya authorisasi"}
        return
      end
      
      begin
        ActiveRecord::Base.transaction do 
          @object.withdraw_compulsory_savings( :compulsory_savings_withdrawn_at => params[:group_loan][:compulsory_savings_withdrawn_at] )
        end
      rescue ActiveRecord::ActiveRecordError  
      else
      end
      
      
    else
      # puts "==========> Inside the update object\n"*100
      # puts "params[:group_loan][:group_number]: #{params[:group_loan][:group_number]}"
      @object.update_object(params[:group_loan])
    end
    
    # @object.update_object( params[:group_loan] )
    if @object.errors.size == 0 
      render :json => { :success => true,   
                        :group_loans => [
                            :id 							=>  	@object.id                  ,
                          	:name 			 										 =>   @object.name                                ,
                          	:group_number                   => @object.group_number, 
                          	:number_of_meetings 						 =>   @object.number_of_meetings                  ,
                          	:number_of_collections					 =>   @object.number_of_collections               ,
                          	:total_members_count             =>   @object.total_members_count, 
                          	:is_started 										 =>   @object.is_started                          ,
                          	:started_at 										 =>   format_date_friendly(@object.started_at)    ,
                          	:is_loan_disbursed 							 =>   @object.is_loan_disbursed                   ,
                          	:disbursed_at 									 =>   format_date_friendly( @object.disbursed_at) ,
                          	:is_closed 											 =>   @object.is_closed                           ,
                          	:closed_at 											 =>   format_date_friendly( @object.closed_at )   ,
                          	:is_compulsory_savings_withdrawn =>   @object.is_compulsory_savings_withdrawn     ,
                            :compulsory_savings_withdrawn_at =>   format_date_friendly( @object.compulsory_savings_withdrawn_at),                            # 
                            :start_fund                               => @object.start_fund,
                            :disbursed_group_loan_memberships_count   => @object.disbursed_group_loan_memberships_count,
                            :disbursed_fund                           => @object.disbursed_fund,
                            :active_group_loan_memberships_count      => @object.active_group_loan_memberships.count,
                          	:non_disbursed_fund => @object.non_disbursed_fund,
                          	:compulsory_savings_return_amount => @object.compulsory_savings_return_amount,
                          	:bad_debt_allowance => @object.bad_debt_allowance,
                          	:bad_debt_expense => @object.bad_debt_expense
                          ],
                        :total => GroupLoan.count  } 
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
    puts "inside the show"
    puts "=============\n"*5
    puts "The params: #{params}"
    @object = GroupLoan.find_by_id params[:id]
    puts "The params[:id]: #{params[:id]}"
    puts "The object: #{@object}"
    render :json => { :success => true, 
                      :group_loans => [
                          :id 						                 =>  	@object.id                  ,
                        	:name 			 										 =>   @object.name                                ,
                        	:group_number                   => @object.group_number, 
                        	:number_of_meetings 						 =>   @object.number_of_meetings                  ,
                        	:number_of_collections					 =>   @object.number_of_collections               ,
                        	:total_members_count             =>   @object.total_members_count, 
                        	:is_started 										 =>   @object.is_started                          ,
                        	:started_at 										 =>   format_date_friendly(@object.started_at)    ,
                        	:is_loan_disbursed 							 =>   @object.is_loan_disbursed                   ,
                        	:disbursed_at 									 =>   format_date_friendly( @object.disbursed_at) ,
                        	:is_closed 											 =>   @object.is_closed                           ,
                        	:closed_at 											 =>   format_date_friendly( @object.closed_at )   ,
                        	:is_compulsory_savings_withdrawn =>   @object.is_compulsory_savings_withdrawn     ,
                        	:compulsory_savings_withdrawn_at =>   format_date_friendly( @object.compulsory_savings_withdrawn_at),                          
                          :start_fund                               => @object.start_fund,
                          :disbursed_group_loan_memberships_count   => @object.disbursed_group_loan_memberships_count,
                          :disbursed_fund                           => @object.disbursed_fund,
                        	:active_group_loan_memberships_count		  => @object.active_group_loan_memberships.count,
                        	:non_disbursed_fund => @object.non_disbursed_fund,
                        	:compulsory_savings_return_amount => @object.compulsory_savings_return_amount,
                        	:bad_debt_allowance => @object.bad_debt_allowance,
                        	:bad_debt_expense => @object.bad_debt_expense
                        	
                        	
                        ] , 
                      :total => Member.count }
  end

  def destroy
    @object = GroupLoan.find(params[:id])
    
    begin
      ActiveRecord::Base.transaction do 
        @object.delete_object 
      end
    rescue ActiveRecord::ActiveRecordError  
    else
    end
    
    
    

    if ( not @object.persisted?   )  
      render :json => { :success => true, :total => GroupLoan.count }  
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
      @objects = GroupLoan.where{ (name =~ query)    
                              }.
                        page(params[:page]).
                        per(params[:limit]).
                        order("id DESC")
                        
      @total = GroupLoan.where{ (name =~ query)    
                              }.count
    else
      @objects = GroupLoan.where{ (id.eq selected_id)   
                              }.
                        page(params[:page]).
                        per(params[:limit]).
                        order("id DESC")
   
      @total = GroupLoan.where{ (id.eq selected_id)   
                              }.count 
    end
    
    
    render :json => { :records => @objects , :total => @total, :success => true }
  end
end
