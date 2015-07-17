class Api2::TransactionDatasController < Api2::BaseReportApiController



  def index
    
    if params[:print_report].present?
    	start_date =  parse_date( params[:start_date] )
	   	end_date =  parse_date( params[:end_date] ) 




	   	@objects = TransactionData.includes(:transaction_data_details => [:account]).where{
	   		( is_confirmed.eq true )  & 
	   		(transaction_datetime.gte start_date) & 
       		( transaction_datetime.lt end_date )
	   	}.page(params[:page]).per(params[:limit]).
	   	order("transaction_datetime ASC")

	   	@total = TransactionData.includes(:transaction_data_details => [:account]).where{
	   		( is_confirmed.eq true )  & 
	   		(transaction_datetime.gte start_date) & 
       		( transaction_datetime.lt end_date )
	   	}.count 

    end
  end

end