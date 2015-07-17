class GroupLoanWeeklyCollectionAttendance < ActiveRecord::Base
  # attr_accessible :title, :body
  # belongs_to :office 

  belongs_to :group_loan_weekly_collection
  belongs_to :member
  belongs_to :group_loan_membership
  
         

  
  def self.active_objects
    self
  end  
  
  def self.create_object(   params) 
    new_object                 = self.new 
    new_object.group_loan_weekly_collection_id            = params[:group_loan_weekly_collection_id]
    new_object.group_loan_membership_id     = params[:group_loan_membership_id] 

    new_object.save 
    return new_object
  end
  
  def update_object( params ) 
    
    self.attendance_status            = params[:attendance_status]
    self.payment_status     = params[:payment_status] 
    
    self.save 

    return self
  end
  
end
