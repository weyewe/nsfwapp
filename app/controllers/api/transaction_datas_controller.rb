class Api::TransactionDatasController < Api::BaseApiController
  
  def index
     
     
     if params[:livesearch].present? 
       livesearch = "%#{params[:livesearch]}%"
       @objects = TransactionData.active_objects.where{
         (is_deleted.eq false ) & 
         (
           (description =~  livesearch ) | 
           ( code =~ livesearch)
         )

       }.page(params[:page]).per(params[:limit]).order("id DESC")

       @total = TransactionData.active_objects.where{
         (is_deleted.eq false ) & 
         (
           (description =~  livesearch ) | 
            ( code =~ livesearch)
         )
       }.count
 
     elsif params[:start_date].present?
       start_date =  parse_date( params[:start_date] )
       end_date =  parse_date( params[:end_date] )
       @objects = TransactionData.where{
          (is_confirmed.eq true ) & 
          (transaction_datetime.gte start_date) & 
          ( transaction_datetime.lt end_date )
         }.page(params[:page]).per(params[:limit]).order("transaction_datetime DESC")


       @total = TransactionData.where{
              (is_confirmed.eq true ) & 
              (transaction_datetime.gte start_date) & 
              ( transaction_datetime.lt end_date )
            }.count

     else
       @objects = TransactionData.active_objects.page(params[:page]).per(params[:limit]).order("id DESC")
       @total = TransactionData.active_objects.count
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
      @objects = TransactionData.where{  (title =~ query)   & 
                                (is_deleted.eq false )
                              }.
                        page(params[:page]).
                        per(params[:limit]).
                        order("id DESC")
    else
      @objects = TransactionData.where{ (id.eq selected_id)  & 
                                (is_deleted.eq false )
                              }.
                        page(params[:page]).
                        per(params[:limit]).
                        order("id DESC")
    end
    
    
    render :json => { :records => @objects , :total => @objects.count, :success => true }
  end
  
  
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
  
  
  def download_transaction_data
    start_date =  parse_date( params[:start_date] )
    end_date =  parse_date( params[:end_date] )
    email = params[:email]
    
    if start_date.nil? 
      render :json => { :message => "Start Date harus ada", :success => false }
      return 
    end
    
    if end_date.nil? 
      render :json => { :message => "End Date harus ada", :success => false }
      return 
    end
    
    if not email.present? 
      render :json => { :message => "Email harus ada", :success => false }
      return 
    end
    
    if start_date > end_date
      render :json => { :message => "Start Date tidak boleh > End Date", :success => false }
      return 
    end
    
    if not ( email =~  VALID_EMAIL_REGEX )
      render :json => { :message => "Email tidak valid", :success => false }
      return
    end
    
    
    # UserMailer.delay.welcome 
    UserMailer.delay.send_transaction_data_download_link( start_date, end_date, email ) 
    render :json => { :message => "Awesome", :success => true }
    
  end
end
