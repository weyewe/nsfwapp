class Api::GroupLoanPrematureClearancePaymentsController < Api::BaseApiController
  
  def index
    
    if params[:livesearch].present? 
      livesearch = "%#{params[:livesearch]}%"
      @objects = GroupLoanPrematureClearancePayment.where{
        (
          (name =~  livesearch )
        )
        
      }.page(params[:page]).per(params[:limit]).order("id DESC")
      
      @total = GroupLoanPrematureClearancePayment.where{ 
        (
          (name =~  livesearch )
        )
      }.count
      
      # calendar
      
    elsif params[:parent_id].present?
      @objects = GroupLoanPrematureClearancePayment.joins(:group_loan_weekly_collection, :group_loan_membership).
                  where(:group_loan_id => params[:parent_id]).
                  page(params[:page]).per(params[:limit]).order("id ASC")
      @total = GroupLoanPrematureClearancePayment.where(:group_loan_id => params[:parent_id]).count 
    else
      @objects = []
      @total = 0 
    end
    
    # render :json => { :group_loan_premature_clearance_payments => @objects , :total => @total , :success => true }
  end
  

  def create
    @object = GroupLoanPrematureClearancePayment.create_object( params[:group_loan_premature_clearance_payment] )
    if @object.errors.size == 0 
      render :json => { :success => true, 
                        :group_loan_premature_clearance_payments => [@object] , 
                        :total => GroupLoanPrematureClearancePayment.count }  
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
    @object = GroupLoanPrematureClearancePayment.find(params[:id])
    
    @object.update_object( params[:group_loan_premature_clearance_payment] )
    if @object.errors.size == 0 
      render :json => { :success => true,   
                        :group_loan_premature_clearance_payments => [@object],
                        :total => GroupLoanPrematureClearancePayment.count  } 
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
    @object = GroupLoanPrematureClearancePayment.find(params[:id])
    @object.delete_object 

    if  not @object.persisted? 
      render :json => { :success => true, :total => GroupLoanPrematureClearancePayment.count }  
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
      @objects = GroupLoanPrematureClearancePayment.where{ (week_number =~ query)    
                              }.
                        page(params[:page]).
                        per(params[:limit]).
                        order("id DESC")
                        
      @total = GroupLoanPrematureClearancePayment.where{ (week_number =~ query)   
                              }.count
    else
      @objects = GroupLoanPrematureClearancePayment.where{ (id.eq selected_id)  
                              }.
                        page(params[:page]).
                        per(params[:limit]).
                        order("id ASC")
   
      @total = GroupLoanPrematureClearancePayment.where{ (id.eq selected_id)  
                              }.count 
    end
    
    
    # render :json => { :records => @objects , :total => @total, :success => true }
  end
end
