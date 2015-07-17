class Api2::GroupLoansController < Api2::BaseReportApiController




  def index
    
    if params[:livesearch].present? 
      livesearch = "%#{params[:livesearch]}%"
      @objects = GroupLoan.includes(:group_loan_weekly_collections).where{
        ( is_loan_disbursed.eq true ) & 
        ( is_closed.eq false ) & 
        (
          (name =~  livesearch ) | 
          (group_number =~ livesearch ) 
        )
        
      }.page(params[:page]).per(params[:limit]).order("group_loans.id DESC")
      
      @total = GroupLoan.where{ 
        ( is_loan_disbursed.eq true ) & 
        ( is_closed.eq false ) & 
        (
          (name =~  livesearch ) | 
          (group_number =~ livesearch ) 
        )
      }.count

    end
  end

  def pending_group_loans
    @objects = [] 
        
        
        today = DateTime.now
        end_of_week = today.end_of_week
        list_of_group_loan_id = GroupLoanWeeklyCollection.where{
          ( is_collected.eq false) & 
          ( tentative_collection_date.lte end_of_week)
        } .map{|x| x.group_loan_id}

        list_of_group_loan_id.uniq!
        
        puts "after extracting problematic group loan id"
        @total_pending = 0 
        GroupLoan.includes(:group_loan_memberships, 
          :group_loan_weekly_collections).
            where( :id => list_of_group_loan_id).
            page(params[:page]).per(params[:limit]).order("disbursed_at ASC").each do |group_loan|

      
            last_collected = group_loan.group_loan_weekly_collections.where(:is_collected => true, :is_confirmed => true ).order("id ASC").last

            collected_at = nil
            collected_at = last_collected.collected_at if not last_collected.nil?

            next_collection_amount = BigDecimal("0")
            next_collection = group_loan.group_loan_weekly_collections.where(:is_collected => false, :is_confirmed => false ).order("id ASC").first

            next_collection_amount = next_collection.amount_receivable if not next_collection.nil? 
            # puts "before result"
            result = [
              group_loan.group_number,
              group_loan.name, 
              group_loan.disbursed_at, 
              group_loan.active_group_loan_memberships.count , 
              group_loan.number_of_collections,
              group_loan.group_loan_weekly_collections.
                  where(:is_collected => true, :is_confirmed => true ).count ,
              collected_at,
              next_collection_amount
            ]               
              # puts "After result"
            @objects <<  result

        end

 
  end

  def disbursed_group_loans
    client_starting_datetime   = params[:starting_datetime].to_datetime 
    client_ending_datetime = params[:ending_datetime].to_datetime 
 
    query = GroupLoan.where{
      (is_loan_disbursed.eq true ) & 
      (disbursed_at.lte client_ending_datetime ) & 
      (disbursed_at.gt client_starting_datetime)
    }.order("disbursed_at ASC")

    @objects = query.page( params[:page]).limit( params[:limit])
    @total = query.count  
  end

end


