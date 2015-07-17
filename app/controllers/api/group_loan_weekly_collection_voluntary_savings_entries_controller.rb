class Api::GroupLoanWeeklyCollectionVoluntarySavingsEntriesController < Api::BaseApiController
  # GroupLoanWeeklyCollectionVoluntarySavingsEntriesController


  def index

    # puts "This is awesome <==========\n"*10

    if params[:livesearch].present? 
      livesearch = "%#{params[:livesearch]}%"
      @objects = GroupLoanWeeklyCollectionVoluntarySavingsEntry.where{
        (
          (name =~  livesearch )
        )
        
      }.page(params[:page]).per(params[:limit]).order("id DESC")
      
      @total = GroupLoanWeeklyCollectionVoluntarySavingsEntry.where{ 
        (
          (name =~  livesearch )
        )
      }.count
      
      # calendar
      
    elsif params[:parent_id].present?
      @objects = GroupLoanWeeklyCollectionVoluntarySavingsEntry. joins(:group_loan_membership => :member).
                  where(:group_loan_weekly_collection_id => params[:parent_id]).
                  page(params[:page]).per(params[:limit]).order("id ASC")
      @total = GroupLoanWeeklyCollectionVoluntarySavingsEntry.where(:group_loan_weekly_collection_id => params[:parent_id]).count 
    else
      @objects = []
      @total = 0 
    end

  end


  def create
    
    @object = GroupLoanWeeklyCollectionVoluntarySavingsEntry.create_object( params[:group_loan_weekly_collection_voluntary_savings_entry] )
    if @object.errors.size == 0 
      render :json => { :success => true, 
                        :group_loan_weekly_collection_voluntary_savings_entries => [@object] , 
                        :total => @object.group_loan_weekly_collection.
                                      group_loan_weekly_collection_voluntary_savings_entries.
                                      count }  
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
    @object = GroupLoanWeeklyCollectionVoluntarySavingsEntry.find(params[:id])

   
    @object.update_object(params[:group_loan_weekly_collection_voluntary_savings_entry])
 
		
		
    if @object.errors.size == 0 
      render :json => { :success => true,   
                        :group_loan_weekly_collection_voluntary_savings_entries => [
                            :id               =>    @object.id                  ,
                            :group_loan_weekly_collection_id      =>     @object.group_loan_weekly_collection_id   ,
                            :group_loan_membership_id    =>    @object.group_loan_membership_id  ,
                            :amount => @object.amount ,
                            :member_name => @object.group_loan_membership.member.name ,
                            :member_id_number => @object.group_loan_membership.member.id_number 

                          ],
                        :total =>   @object.group_loan_weekly_collection.
                                        group_loan_weekly_collection_voluntary_savings_entries.
                                        count
                                        } 
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

  # def show
  #   @object = GroupLoanWeeklyCollectionVoluntarySavingsEntry.find_by_id params[:id] 
  #   render :json => { :success => true, 
  #                     :group_loan_weekly_collection_voluntary_savings_entry_voluntary_savings_entries => [
  #                         :id               =>    @object.id                  ,
  #                         :group_loan_weekly_collection_id      =>     @object.group_loan_weekly_collection_id   ,
  #                         :group_loan_membership_id    =>    @object.group_loan_membership_id  ,
  #                         :amount => @object.amount ,
  #                         :member_name => @object.group_loan_membership.member.name ,
  #                         :member_id_number => @object.group_loan_membership.member.id_number
  # 
  # 
  #                       ] , 
  #                     :total => GroupLoanWeeklyCollectionVoluntarySavingsEntry.count }
  # end

  def destroy
    @object = GroupLoanWeeklyCollectionVoluntarySavingsEntry.find(params[:id])
    @parent_object = @object.group_loan_weekly_collection
    @object.delete_object 
    
    if ( not @object.persisted?   ) and @object.errors.size == 0 
      render :json => { :success => true, :total => @parent_object.
                                                group_loan_weekly_collection_voluntary_savings_entries.
                                                count }  
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


  
end

