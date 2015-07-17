class Api2::MembershipSavingsReportsController < Api2::BaseReportApiController
  
  def index

    client_starting_datetime   = params[:starting_datetime].to_datetime 
    client_ending_datetime = params[:ending_datetime].to_datetime 

  #     today_kki_date = DateTime.now.in_time_zone 'Jakarta'
  # last_year = today_kki_date - 1.years
  # beginning_of_last_year = last_year.beginning_of_year
  # ending_of_last_year = last_year.end_of_year
  # starting_datetime = beginning_of_last_year.utc 
  # ending_datetime = ending_of_last_year.utc 
  #   client_starting_datetime = starting_datetime
  #   client_ending_datetime =  ending_datetime



    # @objects = Member.includes(:savings_entries).where(
    #     :savings_entries => { :savings_status => SAVINGS_STATUS[:membership] }
    #   ).page( 1 ).limit(  10) .order("members.id ASC")


    @objects = Member.includes(:savings_entries).where{
      ( savings_entries.savings_status.eq SAVINGS_STATUS[:membership] ) & 
      ( savings_entries.confirmed_at.lte client_ending_datetime ) & 
      ( savings_entries.confirmed_at.gte client_starting_datetime)

    }.page( params[:page]).limit( params[:limit]).order("members.id ASC")

    @total = Member.includes(:savings_entries).where{
      ( savings_entries.savings_status.eq SAVINGS_STATUS[:membership] ) & 
      ( savings_entries.confirmed_at.lte client_ending_datetime ) & 
      ( savings_entries.confirmed_at.gte client_starting_datetime)

    }.count

  end

end



