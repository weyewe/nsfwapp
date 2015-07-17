class Api2::SubRedditsController < Api2::BaseReportApiController 
  skip_before_filter :authenticate_auth_token, :only => [:create, :destroy, :index ]
  skip_before_filter :ensure_authorized, :only => [:create, :destroy, :index ]
  
   
  respond_to :json
  
  def index
     
    
    @objects = SubReddit.order("id ASC").load 
    @total = @objects.count 
    
  end 
 
end