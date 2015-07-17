class Api2::SavingsEntryReportsController < Api2::BaseReportApiController
  
  def index
    client_starting_datetime   = params[:starting_datetime].to_datetime 
    client_ending_datetime = params[:ending_datetime].to_datetime 

    @objects = SavingsEntry.includes(:member).where(
      :savings_status => SAVINGS_STATUS[:membership] 
    ).where{
        (confirmed_at.not_eq nil) & 
        
        (confirmed_at.lte client_ending_datetime ) & 
        (confirmed_at.gt client_starting_datetime)

    }.page( params[:page]).limit( params[:limit]).order("confirmed_at ASC")


    @total = SavingsEntry.includes(:member).where(
      :savings_status => SAVINGS_STATUS[:membership] 
    ).where{
        (confirmed_at.not_eq nil) & 
        
        (confirmed_at.lte client_ending_datetime ) & 
        (confirmed_at.gt client_starting_datetime)

    }.count

  end

  def member_history
    member = Member.find_by_id_number params[:id_number]

    @objects = member.savings_entries.


              where(:savings_status => SAVINGS_STATUS[:savings_account], :is_confirmed => true ).
              order("confirmed_at ASC")

    @total = @objects.count 
  end

end




=begin
SavingsEntry.where{
  (is_confirmed.eq true )  & 
  ( savings_status.eq SAVINGS_STATUS[:savings_account]) & 
  ( confirmed_at.eq nil )

}.first
  
=end