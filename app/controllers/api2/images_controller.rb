class Api2::ImagesController < Api2::BaseReportApiController 
  skip_before_filter :authenticate_auth_token, :only => [:create, :destroy, :index ]
  skip_before_filter :ensure_authorized, :only => [:create, :destroy, :index ]
  
   
  respond_to :json
  
  def index
    
    today  = DateTime.now
    yesterday  = today - 1.days
    
    start_of_today = today.begining_of_day
    end_of_today = today.end_of_day
    
    @parent = SubReddit.find_by_id params[:parent_id]
    query = Image.where(:sub_reddit_id => @parent.id).where{
        ( created_at.gte start_of_today) & 
        ( created_at.lt end_of_today)
    }.order("id ASC")
    
    @objects = query 
    @total = query.count 
    
  end 
 
end