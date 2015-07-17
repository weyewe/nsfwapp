class Api::TransactionDataDetailsController < Api::BaseApiController
  
  def index
    @parent = TransactionData.find_by_id params[:transaction_data_id]
    @objects = @parent.transaction_data_details.joins(:transaction_data, :account).page(params[:page]).per(params[:limit]).order("id DESC")
    @total = @parent.transaction_data_details.count
  end

end
