class Api::GroupLoanWeeklyCollectionAttendancesController < Api::BaseApiController

  def index
 
      @objects = GroupLoanWeeklyCollectionAttendance.joins(:group_loan_membership => :member).
                  where(:group_loan_weekly_collection_id => params[:parent_id]).
                  page(params[:page]).per(params[:limit]).order("id ASC")
      @total = GroupLoanWeeklyCollectionAttendance.where(:group_loan_weekly_collection_id => params[:parent_id]).count 
    

  end

  def update
    @object = GroupLoanWeeklyCollectionAttendance.find(params[:id])

   
    @object.update_object(params[:group_loan_weekly_collection_attendance])
 
		
		
    if @object.errors.size == 0 
      render :json => { :success => true,   
                        :group_loan_weekly_collection_attendances => [
                            :id               =>    @object.id                  ,
                            :group_loan_weekly_collection_id      =>     @object.group_loan_weekly_collection_id   ,
                            :group_loan_membership_id    =>    @object.group_loan_membership_id  ,
                            :member_name => @object.group_loan_membership.member.name  ,
                            :attendance_status => @object.attendance_status,
                            :payment_status => @object.payment_status

                          ],
                        :total =>   @object.group_loan_weekly_collection.
                                        group_loan_weekly_collection_attendances.
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

  
end

