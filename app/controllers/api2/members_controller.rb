class Api2::MembersController < Api2::BaseReportApiController
  


  def get_total_members
    render :json => { :success => true, 
                      :total => Member.count   }
  end

end

# data_required_by 
