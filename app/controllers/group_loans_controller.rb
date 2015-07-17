require 'csv'

class GroupLoansController < ApplicationController
  def download_pending
    @group_loans = GroupLoan.joins(:group_loan_weekly_collections).where(:is_started => true, :is_closed => false ) 
    
    # CSV.open("data.csv", "wb") do |csv|
    #   csv << data_filtered.first.keys
    #   data_filtered.each do |hash|
    #     csv << hash.values
    #   end
    # end
    # 
    # 
    # send_data file, :type => 'text/csv; charset=iso-8859-1; header=present', :disposition => "attachment;data=#{csv_file}.csv"
    
    send_data @group_loans.to_csv
  end
end


=begin
  Today is the week x
    Get all weekly_collections with tentative_collection_date at week x, but uncollected
    
    Extract the group info.
    
    today = DateTime.now
    end_of_week = today.end_of_week
    list_of_group_loan_id = GroupLoanWeeklyCollection.where{
      ( is_collected.eq false) & 
      ( tentative_collection_date.lte end_of_week)
    } .map{|x| x.group_loan_id}
    
    list_of_group_loan_id.uniq!
    GroupLoan.includes(:group_loan_memberships, :group_loan_weekly_collections).where( :id => list_of_group_loan_id).count
  
=end