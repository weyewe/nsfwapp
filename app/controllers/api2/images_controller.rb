class Api2::ImagesController < Api2::BaseReportApiController 
  skip_before_filter :authenticate_auth_token, :only => [:create, :destroy, :index ]
  skip_before_filter :ensure_authorized, :only => [:create, :destroy, :index ]
  
   
  respond_to :json
  
  def index
    
    today  = DateTime.now
 
    
    
    today_yday = Date.today.yday().to_i
    today_year  = Date.today.year.to_i
    
    @parent = SubReddit.find_by_id params[:parent_id]
    query = Image.where(
      :sub_reddit_id => @parent.id,
      :yday => today_yday,
      :year => today_year
      
      ).order("id ASC")
    
    @objects = query 
    @total = query.count 
    
  end 
 
end