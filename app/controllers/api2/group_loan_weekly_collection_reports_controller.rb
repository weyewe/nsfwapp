class Api2::GroupLoanWeeklyCollectionReportsController < Api2::BaseReportApiController
  
=begin
  # in jakarta, it is GMT + 7 
  # in server, it is UTC time => GMT + 0 

  tomorrow = DateTime.now + 1.days
  tomorrow_last_week = tomorrow - 1.weeks 

  # if today is sunday
  monday = DateTime.now + 1.days
  last_monday = monday - 1.weeks 

  # we want the report to be processed at 9pm. which means, it is 2pm Server time (UTC)

  today = DateTime.now 
  tomorrow = DateTime.now + 1 
  today_starting_hour = today.beginning_of_day
  today_ending_hour = today.end_of_day

  client_today_starting_hour = today_starting_hour + 7.hours
  client_today_ending_hour  = today_ending_hour + 7.hours

#tomorrow_string = DateTime.now.to_s
# parsed_datetime = tomorrow_string.to_datetime
  
  "2015-05-25T09:21:46+00:00"
=end

  def index
    client_starting_datetime   = params[:starting_datetime].to_datetime 
    client_ending_datetime = params[:ending_datetime].to_datetime 
=begin
    today_kki_date = DateTime.now.in_time_zone 'Jakarta'
  weekly_collection_report_disburse_day = today_kki_date  + 2.days
   last_week_report_data = weekly_collection_report_disburse_day - 1.weeks
  client_starting_datetime = last_week_report_data.beginning_of_day.utc
  client_ending_datetime =  last_week_report_data.end_of_day.utc
=end


    @objects = GroupLoanWeeklyCollection.joins(:group_loan).where{
      (is_collected.eq true ) & 
      (is_confirmed.eq true ) & 

      (confirmed_at.gte client_starting_datetime ) & 
      (confirmed_at.lte client_ending_datetime )
    }.order("group_loans.group_number DESC")

    @total = @objects.count 

  
  end
  

  def show
  	@object  = GroupLoanWeeklyCollection.find_by_id params[:id]
  	@objects =[]

  	@group_loan = @object.group_loan
  	@active_glm_list = @object.active_group_loan_memberships.joins(:group_loan_product).order("id ASC")
	  @glwc_attendance_list  = @object.group_loan_weekly_collection_attendances
   	@glwc_voluntary_savings_list = @object.group_loan_weekly_collection_voluntary_savings_entries
  

  	@active_glm_list.each do |active_glm|

  	  member = active_glm.member 
      member_name = active_glm.member.name 
      glp = active_glm.group_loan_product
      glwc_attendance = @glwc_attendance_list.where(
          :group_loan_membership_id => active_glm.id 
        ).first

      glwc_voluntary_savings = @glwc_voluntary_savings_list.where(
          :group_loan_membership_id => active_glm.id 
        ).first

      withdrawal_amount = BigDecimal("0")
      addition_amount = BigDecimal("0")

      if not glwc_voluntary_savings.nil?
        if glwc_voluntary_savings.direction == FUND_TRANSFER_DIRECTION[:incoming]
          addition_amount = glwc_voluntary_savings.amount 
        else
          withdrawal_amount = glwc_voluntary_savings.amount 
        end
      end
      
      
      payment_status = "ya"
      attendance_status = "ya"
      payment_status = "no" if glwc_attendance.payment_status == false
      attendance_status = "no" if glwc_attendance.attendance_status == false 
      
      remaining_amount = ( @group_loan.number_of_collections - @object.week_number ) *
                        glp.weekly_payment_amount

      total_principal_adjusted =  ( ( glp.principal * glp.total_weeks ) /1000 ).to_s.gsub(".0",'')
      total_installment_adjusted = ( ( glp.weekly_payment_amount ) /1000 ).to_s.gsub(".0",'')
      savings_addition_adjusted = ( ( addition_amount) /1000 ).to_s.gsub(".0",'')
      savings_withdrawal_adjusted = ( ( withdrawal_amount) /1000 ).to_s.gsub(".0",'')
      remaining_savings_adjusted = ( ( member.total_savings_account) /1000 ).to_s.gsub(".0",'')
      remaining_amount_adjusted = ( ( remaining_amount) /1000 ).to_s.gsub(".0",'')

      total_dtr = GroupLoanWeeklyCollectionAttendance.where(
          :group_loan_membership_id => active_glm.id,
          :group_loan_weekly_collection_id => @glwc_id_list,
          :payment_status => false
        ).count 

      total_telat = GroupLoanWeeklyCollectionAttendance.where(
          :group_loan_membership_id => active_glm.id,
          :group_loan_weekly_collection_id => @glwc_id_list,
          :attendance_status => false
        ).count 


  		@objects << {
  			:member_name					 	=> "#{member.name}",
  			:member_id_number					=> "#{member.id_number}",
  			:total_principal_adjusted 			=> "#{ total_principal_adjusted }",
  			:total_installment_adjusted 		=> "#{ total_installment_adjusted }",
  			:payment_status 					=> "#{payment_status}", # bayar
  			:attendance_status 					=> "#{attendance_status}", #  tepat waktu
  			:savings_addition_adjusted 			=> "#{savings_addition_adjusted}", # menabung minggu lalu
  			:savings_withdrawal_adjusted 		=> "#{savings_withdrawal_adjusted}", # ambil tab minggu lalu
  			:remaining_savings_adjusted			=> "#{ remaining_savings_adjusted }" , # saldo sisa tabungan pribadi
  			:remaining_amount_adjusted			=> "#{remaining_amount_adjusted}",  # sisa pinjaman
  			:total_dtr							=> "#{total_dtr}", 
  			:total_telat						=>	"#{total_telat}"
  		}


  	end

  	render :json => { :success => true, 
                      :week_number => @object.week_number, 
                      :confirmed_at => @object.confirmed_at.to_datetime.to_s , 
                      :group_loan_name => @group_loan.name, 
                      :group_loan_group_number => @group_loan.group_number,

                      :group_loan_weekly_collection_report_details => @objects  }
    return 
  end

end

# data_required_by 
