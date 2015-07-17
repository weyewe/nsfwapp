require 'csv'
require 'writeexcel'

=begin
  data = SalaryResult::PaymentSlip.extract_result
  SalaryResult::PaymentSlip.send_salary_slip_to_employee( data ) 
=end
module SalaryResult
  class PaymentSlip

    def self.extract_amount( value) 
      return BigDecimal('0') if not value.present? 
        
      
      if value.is_a? String
        value = value.gsub(',', '')
        return BigDecimal( value ) 
      elsif value.is_a? Integer
        return BigDecimal( value.to_s)
      end
      
      return BigDecimal('0')
    end

    def self.parse_date( date_string) 
      return nil if not date_string.present?
    # puts "'The date_string: ' :#{date_string}"
    # month/day/year
    
      begin 
        date_array = date_string.split('/').map{|x| x.to_i}
       
        
        datetime = DateTime.new( date_array[2], 
                                  date_array[0], 
                                  date_array[1], 
                                   0, 
                                   0, 
                                   0,
                      Rational( UTC_OFFSET , 24) )
                    
                    
        return datetime.utc
      rescue Exception => e
        return nil 
      end
    end


    def self.extract_result
      filename = "#{Rails.root}/play_data/awesome.csv"

      result_array = [] 
      
      CSV.open(filename, 'r') do |csv| 
         
        fail_member_id_array = [] 
        
        csv.each do |x|
          element = [] 
          puts "\n\n"
          # puts "#{x.inspect}"
          puts "nama : #{x[0]}"
          element << x[0]
          puts "email : #{x[1]}"
          element << x[1]
          puts "tanggal bergabung : #{x[2]}"
          element << x[2]
          puts "jabatan: #{x[3]}"
          element << x[3]
          puts "lokasi: #{x[4]}"
          element << x[4]
          puts "rekening_bca: #{x[5] }"
          element << x[5]
          puts "jumlah hari kerja: #{x[7]}"
          element << x[7]
          puts "cuti: #{x[8] }"
          element << x[8]
          puts "absen: #{ x[9] }"
          element << x[9]
          puts "gaji pokok: #{self.extract_amount( x[10] )}"
          element <<   x[10] 
          puts "tunjangan masa kerja: #{self.extract_amount( x[11] )}"
          element <<   x[11] 
          puts "tunjangan hadir: #{self.extract_amount( x[12] )}"
          element <<  x[12] 
          puts "tunjangan transport: #{self.extract_amount( x[13] )}"
          element <<   x[13] 
          puts "tunjangan makan: #{self.extract_amount( x[14] )}"
          element <<   x[14] 

          puts "potongan asuransi: #{self.extract_amount( x[15] )}"
          element <<   x[15] 
          puts "potongan koperasi: #{self.extract_amount( x[16] )}"
          element <<   x[16] 

          puts "Total: #{self.extract_amount( x[17] )}"
          element <<  x[17] 

          result_array << element 
        end
      end

      return result_array


    end

    def self.send_salary_slip_to_employee(data)





      target_employee = data.first 

      data.each do |element|
        UserMailer.send_slip_gaji( element )
      end
      

      



    end
  end
end
