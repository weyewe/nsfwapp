class Api::LoanTrailsController < Api::BaseApiController
  
  def index
      @parent = Member.find_by_id params[:parent_id]
 
      @objects = @parent.group_loan_memberships.joins(:group_loan, :group_loan_product).
                  page(params[:page]).per(params[:limit]).order("group_loan_memberships.id DESC")

      @total = @parent.group_loan_memberships.count
   
    # render :json => { :savings_entries => @objects , :total => @total , :success => true }
  end
  
 
end
