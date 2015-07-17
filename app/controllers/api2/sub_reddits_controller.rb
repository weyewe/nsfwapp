class Api2::SubRedditsController < Api2::BaseReportApiController 
  skip_before_filter :authenticate_auth_token, :only => [:create, :destroy, :index ]
  skip_before_filter :ensure_authorized, :only => [:create, :destroy, :index ]
  
   
  respond_to :json
  
  def index
    
    today  = DateTime.now
    yesterday  = today - 1.days
    
    start_of_yesterday = yesterday.begining_of_day
    end_of_yesterday = yesterday.end_of_day
    
    @objects = SubReddit.order("id ASC").all 
    @total = @objects.count 
    
  end 
 
end