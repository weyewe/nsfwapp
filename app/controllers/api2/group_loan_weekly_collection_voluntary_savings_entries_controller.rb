class Api2::GroupLoanWeeklyCollectionVoluntarySavingsEntriesController < Api2::BaseReportApiController



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


