class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  
  def parse_date( date_string) 
    return nil if not date_string.present?
    # puts "'The date_string: ' :#{date_string}"
    date_array = date_string.split('-').map{|x| x.to_i}
     
     
    # puts "inside parse date\n"*10
    # puts "0: #{date_array[0]}"
    # puts "0: #{date_array[1]}"
    # puts "0: #{date_array[2]}"
    # puts "\n\n"
   
    datetime = DateTime.new( date_array[0], 
                              date_array[1], 
                              date_array[2], 
                               0, 
                               0, 
                               0,
                  Rational( UTC_OFFSET , 24) )
                  
                  
    return datetime.utc
  end
  
end
