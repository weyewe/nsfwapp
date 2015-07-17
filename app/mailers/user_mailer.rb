# UserMailer.notify_new_user_registration( new_object , password    ).deliver

class UserMailer < ActionMailer::Base
  require 'csv'
  
  default from: "w.yunnal@gmail.com"

  def welcome 
    content = 'awesome banzai'
    # attachments['text.txt'] = {:mime_type => 'text/plain',
    #    :content => content }
    #  
    
    mail(:to => "w.yunnal@gmail.com", :subject => "banzai New account information") 
  end
  
  def sales_for_yesterday 
    
    base_filename = "awesome.csv"
    filename = "#{Rails.root}/public/#{base_filename}"
    
    begin
      CSV.open(filename, 'w') do |csv|
        csv << ['Report']
        csv << ['Name','Product', 'Item Count']
        # products.each do |product|
        #   csv << [user_name, product.title,product.count]
        # end
      end
    rescue Exception => e
      puts e
    end
    
    
    attachments[ "#{base_filename}"] = File.read(filename )
    mail(:to => "admin@11ina.com", :subject => "Registered")
  end
  
  def savings_report( month, year, number_of_months, selected_savings_status) 
    
    base_filename = "savings_report_#{month}_#{year}.csv"
    filename = "#{Rails.root}/public/#{base_filename}"
    
    
    first_savings_entry =  SavingsEntry.where(:is_confirmed => true, :savings_status => selected_savings_status ).order("confirmed_at ASC").first 
    beginning_of_month =  first_savings_entry.confirmed_at.beginning_of_month
    now = DateTime.now
    
    
    begin
      CSV.open(filename, 'w') do |csv|
        
        # header
        header_array = ["MemberId", "Name"]
        current_month = beginning_of_month
        
        while current_month < now
          header_array << "#{current_month.month}/#{current_month.year}"
          current_month =  current_month + 1.month 
        end
        
        header_array << "#{now.day}/#{now.month}/#{now.year}"
        csv << header_array
        
        
        
        # content 
        

        # UserMailer.savings_report(8,2014,5,0).deliver
        
        # current month
        # csv << ['MemberID','Name', 'Voluntary Savings Jan', 'Voluntary Savings Feb', 'Voluntary Savings March', 'Voluntary Savings April', 'Voluntary Savings May', 'Voluntary Savings Jun','Voluntary Savings July', 'Voluntary Savings August' ]
        # count = 0 
                
                 Member.includes(:valid_comb_savings_entries).find_each do |member|
                   # count = count + 1
                   #                   break if count == 10
                   current_month = first_savings_entry.confirmed_at.beginning_of_month 
                   
                   
                   
                   member_data = []
                   
                   member_data << member.id_number
                   member_data << member.name 
                   
                   
                   while current_month <= now do 
                     current_month_valid_comb = member.valid_comb_savings_entries.where(
                       :month => current_month.month,
                       :year => current_month.year,
                       :member_id => member.id 
                     ).first
                 
                     if current_month_valid_comb.nil?
                       member_data << BigDecimal("0")
                     else
                       member_data << current_month_valid_comb.amount 
                     end
                 
                     current_month = current_month + 1.month
                   end
                   
                   member_data << member.total_savings_account
                   csv  << member_data
                   
                   
                 end
                       
      
      end
    rescue Exception => e
      puts e
    end
    
    
    attachments[ "#{base_filename}"] = File.read(filename )
    mail(:to => "admin@11ina.com", :subject => "Registered")
  end
  
  def savings_entry_adjustments_report
    base_filename = "adjustments_report_#{DateTime.now.to_s}.csv"
    filename = "#{Rails.root}/public/#{base_filename}"
    
     
    
    begin
      CSV.open(filename, 'w') do |csv|
        
        # header
        header_array = ["MemberId", "Name", "Savings Amount", "Savings Status", "ConfirmationDate"]
       
        csv << header_array
        

        SavingsEntry.joins(:member).where(:is_adjustment => true, :is_confirmed =>true ).order("confirmed_at ASC").find_each do |savings_entry|
          puts "x"
          
          savings_data = []
          savings_data << savings_entry.member.id_number
          savings_data << savings_entry.member.name 
          savings_data << savings_entry.amount
          
           
          
          savings_status_text = "" 
          if savings_entry.savings_status == SAVINGS_STATUS[:savings_account]
            savings_status_text = "Sukarela"
          elsif savings_entry.savings_status == SAVINGS_STATUS[:membership]
            savings_status_text = "Keanggotaan"
          elsif savings_entry.savings_status == SAVINGS_STATUS[:locked]
            savings_status_text = "Locked"
          end
          
          savings_data << savings_status_text
          savings_data << savings_entry.confirmed_at.to_s
          
           
          csv  << savings_data


        end

      
      end
    rescue Exception => e
      puts e
    end
    
    
    attachments[ "#{base_filename}"] = File.read(filename )
    mail(:to => "admin@11ina.com", :subject => "Adjustment")
  end
  
  def pending_group_loan(email)
    base_filename = "pending_group_loan_#{DateTime.now.to_s}.csv"
    filename = "#{Rails.root}/public/#{base_filename}"
    
    puts "pending group loan"
     
    
    begin
      CSV.open(filename, 'w') do |csv|
        
        # header
        
        header_array = [
            "Group No",
            "Nama Kelompok",
            "Disbursement Date",
            "Jumlah Anggota Aktif",
            "Jumlah Minggu Setoran",
            "Jumlah Minggu Terbayar",
            "Last Payment Date",
            "Jumlah Setoran Berikutnya"
          ]
          
        csv << header_array
        puts "after header array"
        
        
        today = DateTime.now
        end_of_week = today.end_of_week
        list_of_group_loan_id = GroupLoanWeeklyCollection.where{
          ( is_collected.eq false) & 
          ( tentative_collection_date.lte end_of_week)
        } .map{|x| x.group_loan_id}

        list_of_group_loan_id.uniq!
        
        puts "after extracting problematic group loan id"
        @total_pending = 0 
        GroupLoan.includes(:group_loan_memberships, :group_loan_weekly_collections).where( :id => list_of_group_loan_id).order("disbursed_at ASC").each do |group_loan|
          @total_pending += 1
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
              group_loan.group_loan_weekly_collections.where(:is_collected => true, :is_confirmed => true ).count ,
              collected_at,
              next_collection_amount
            ]
            # puts "After result"
          csv <<  result
          
        end
      end
    rescue Exception => e
      puts e
    end
    
    
    attachments[ "#{base_filename}"] = File.read(filename )
    mail(:to => email, :subject => "Pending Group Loan #{DateTime.now}")
  end
  
  
  def send_transaction_data(start_date, end_date, email)
    @awesome_start_date = start_date
    @awesome_end_date = end_date 
    target = ["w.yunnal@gmail.com"]
    target << email 
    
    @objects_length = TransactionData.where{
      (is_confirmed.eq true ) & 
      (transaction_datetime.gte start_date) & 
      ( transaction_datetime.lt end_date )
      }.order("transaction_datetime DESC").count


   
     
    @awesome_filename = "TransactionReport-#{start_date}_to_#{end_date}.xls"
    @filepath = "#{Rails.root}/tmp/" + @awesome_filename
    
     
    # File.delete( @filepath ) if File.exists?( @filepath )
    if File.exists?( @filepath )
      puts "234 the file at #{@filepath} EXISTS"
      File.delete( @filepath ) 
    end
    
    
    
    workbook = WriteExcel.new( @filepath )
      
    worksheet = workbook.add_worksheet
    
    
    row = 0 
    
    worksheet.set_column(TRANSACTION_DESCRIPTION, TRANSACTION_DESCRIPTION,  50) # Column  A   width set to 20
    worksheet.set_column(TRANSACTION_DATETIME, TRANSACTION_DATETIME,  25)
    
    worksheet.set_column(DEBIT_ACCOUNT_NAME, DEBIT_ACCOUNT_NAME,  30)
    worksheet.set_column(CREDIT_ACCOUNT_NAME, CREDIT_ACCOUNT_NAME,  30)
    
    worksheet.set_column(DEBIT_AMOUNT, DEBIT_AMOUNT,  20)
    worksheet.set_column(CREDIT_AMOUNT, CREDIT_AMOUNT,  20)
    
    
    worksheet.write(0, TRANSACTION_NUMBER_COLUMN  , 'NO')
    worksheet.write(0, TRANSACTION_DESCRIPTION  , 'Transaksi')
    worksheet.write(0, TRANSACTION_DATETIME  , 'Tanggal Transaksi')
    worksheet.write(0, DEBIT_ACCOUNT_NAME  , 'Akun Di Debit')
    worksheet.write(0, DEBIT_AMOUNT  , 'Jumlah')
    worksheet.write(0, CREDIT_ACCOUNT_NAME  , 'Akun di kredit')
    worksheet.write(0, CREDIT_AMOUNT  , 'Jumlah')
    
    row += 1
    entry_number  = 1 
    TransactionData.eager_load(:transaction_data_details => [:account]).where{
      (is_confirmed.eq true ) & 
      (transaction_datetime.gte start_date) & 
      ( transaction_datetime.lt end_date )
      }.order("transaction_datetime DESC").find_each do |transaction|
      debit_transaction_array = transaction.transaction_data_details.where(
        :entry_case => NORMAL_BALANCE[:debit]
      )
    
      credit_transaction_array =   transaction.transaction_data_details.where(
        :entry_case => NORMAL_BALANCE[:credit]
      )
    
      worksheet.write(row, TRANSACTION_NUMBER_COLUMN  ,  entry_number )
      worksheet.write(row, TRANSACTION_DESCRIPTION  , transaction.description )
      worksheet.write(row, TRANSACTION_DATETIME  , transaction.transaction_datetime )
    
      counter = 0 
      debit_transaction_array.each do |transaction_data_detail|
        worksheet.write(row + counter, DEBIT_ACCOUNT_NAME  , transaction_data_detail.account.name)
        worksheet.write(row + counter, DEBIT_AMOUNT  , transaction_data_detail.amount )
        counter += 1 
      end
    
      counter = 0 
      credit_transaction_array.each do |transaction_data_detail|
        worksheet.write(row + counter, CREDIT_ACCOUNT_NAME  , transaction_data_detail.account.name)
        worksheet.write(row + counter, CREDIT_AMOUNT  , transaction_data_detail.amount )
        counter += 1 
      end
    
    
    
      length = debit_transaction_array.length
      length = credit_transaction_array.length if credit_transaction_array.length > debit_transaction_array.length
    
    
      row += length   + 1 
      entry_number += 1
    end
    
    workbook.close
    
     
     
    
    attachments[ "#{@awesome_filename}"] = File.read(@filepath )
    mail(:to => email, :subject => "Transaction_data #{DateTime.now}")
  end
  
  
  def send_transaction_data_download_link( start_date, end_date, email )  
    content = 'awesome banzai'
    mail_list = ["w.yunnal@gmail.com"]
    mail_list << email 
    
    
    @awesome_start_date = start_date
    @awesome_end_date = end_date 
    
    @objects_length = TransactionData.where{
      (is_confirmed.eq true ) & 
      (transaction_datetime.gte start_date) & 
      ( transaction_datetime.lt end_date )
      }.order("transaction_datetime DESC").count


   
     
    @awesome_filename = "TransactionReport-#{start_date.to_date}_to_#{end_date.to_date}.xls"
    @filepath = "#{Rails.root}/tmp/" + @awesome_filename
    
     
    # File.delete( @filepath ) if File.exists?( @filepath )
    if File.exists?( @filepath )
      puts "234 the file at #{@filepath} EXISTS"
      File.delete( @filepath ) 
    end
    
    
    
    workbook = WriteExcel.new( @filepath )
      
    worksheet = workbook.add_worksheet
    
    
    row = 0 
    
    worksheet.set_column(TRANSACTION_DESCRIPTION, TRANSACTION_DESCRIPTION,  50) # Column  A   width set to 20
    worksheet.set_column(TRANSACTION_DATETIME, TRANSACTION_DATETIME,  25)
    
    worksheet.set_column(DEBIT_ACCOUNT_NAME, DEBIT_ACCOUNT_NAME,  30)
    worksheet.set_column(CREDIT_ACCOUNT_NAME, CREDIT_ACCOUNT_NAME,  30)
    
    worksheet.set_column(DEBIT_AMOUNT, DEBIT_AMOUNT,  20)
    worksheet.set_column(CREDIT_AMOUNT, CREDIT_AMOUNT,  20)
    
    
    worksheet.write(0, TRANSACTION_NUMBER_COLUMN  , 'NO')
    worksheet.write(0, TRANSACTION_DESCRIPTION  , 'Transaksi')
    worksheet.write(0, TRANSACTION_DATETIME  , 'Tanggal Transaksi')
    worksheet.write(0, DEBIT_ACCOUNT_NAME  , 'Akun Di Debit')
    worksheet.write(0, DEBIT_AMOUNT  , 'Jumlah')
    worksheet.write(0, CREDIT_ACCOUNT_NAME  , 'Akun di kredit')
    worksheet.write(0, CREDIT_AMOUNT  , 'Jumlah')
=begin
result = TransactionData.eager_load(:transaction_data_details => [:account]).where{
    (is_confirmed.eq true ) & 
    (transaction_datetime.gte start_date) & 
    ( transaction_datetime.lt end_date )
  }.order("transaction_datetime DESC").limit(1000).map{|x| x.transaction_datetime}
=end 
    
    
    row += 1
    entry_number  = 1 
    TransactionData.eager_load(:transaction_data_details => [:account]).where{
        (is_confirmed.eq true ) & 
        (transaction_datetime.gte start_date) & 
        ( transaction_datetime.lt end_date )
      }.order("transaction_datetime ASC").find_each do |transaction|
        
      debit_transaction_array = transaction.transaction_data_details.where(
        :entry_case => NORMAL_BALANCE[:debit]
      )
    
      credit_transaction_array =   transaction.transaction_data_details.where(
        :entry_case => NORMAL_BALANCE[:credit]
      )
    
      worksheet.write(row, TRANSACTION_NUMBER_COLUMN  ,  entry_number )
      worksheet.write(row, TRANSACTION_DESCRIPTION  , transaction.description )
      worksheet.write(row, TRANSACTION_DATETIME  , transaction.transaction_datetime )
    
      counter = 0 
      debit_transaction_array.each do |transaction_data_detail|
        worksheet.write(row + counter, DEBIT_ACCOUNT_NAME  , transaction_data_detail.account.name)
        worksheet.write(row + counter, DEBIT_AMOUNT  , transaction_data_detail.amount )
        counter += 1 
      end
    
      counter = 0 
      credit_transaction_array.each do |transaction_data_detail|
        worksheet.write(row + counter, CREDIT_ACCOUNT_NAME  , transaction_data_detail.account.name)
        worksheet.write(row + counter, CREDIT_AMOUNT  , transaction_data_detail.amount )
        counter += 1 
      end
    
    
    
      length = debit_transaction_array.length
      length = credit_transaction_array.length if credit_transaction_array.length > debit_transaction_array.length
    
    
      row += length   + 1 
      entry_number += 1
    end
    
    workbook.close
    
    
=begin
  UPLOADING DATA TO THE S3
=end

    puts "Gonna upload to s3!!!"

    connection = Fog::Storage.new({
      :provider                 => 'AWS',
      :aws_access_key_id        => Figaro.env.s3_key ,
      :aws_secret_access_key    => Figaro.env.s3_secret 
    })
    directory = connection.directories.get( Figaro.env.s3_bucket  ) 
    
    file = directory.files.create(
      :key    => @awesome_filename,
      :body   => File.open( @filepath ),
      :public => true
    )
    
    @public_url = file.public_url 
    puts "The public url: #{@public_url}"
    
    
    
    now = DateTime.now
    
    mail(:to => mail_list, :subject => "Transaction Data Report #{now.year}-#{now.month}-#{now.day}") 
  end
  
=begin
  start_date = DateTime.new(2011,1,1,0,0,0)
  end_date = DateTime.new(2014,12,30,0,0,0)
  email = "isabella.harefa@gmail.com"
  
  
  example use case:
  # with delayed_job
  Notifier.delay.signup(@user)
  UserMailer.delay.send_locked_savings_download_link( start_date, end_date, email )  
=end
  def send_locked_savings_download_link( start_date, end_date, email )  
    content = 'awesome banzai'
    mail_list = ["w.yunnal@gmail.com"]
    mail_list << email 
    
    
    @awesome_start_date = start_date
    @awesome_end_date = end_date 
    
     
=begin
SavingsEntry.where{
  (is_confirmed.eq true ) & 
  (savings_status.eq SAVINGS_STATUS[:locked])
}.count
=end
		
    
    @objects_length = SavingsEntry.where{
      (is_confirmed.eq true ) & 
      (savings_status.eq SAVINGS_STATUS[:locked]) &
      (confirmed_at.gte start_date) & 
      ( confirmed_at.lt end_date )
      
    }.count


   
     
    @awesome_filename = "LockedSavings-#{start_date.to_date}_to_#{end_date.to_date}.xls"
    @filepath = "#{Rails.root}/tmp/" + @awesome_filename
    
     
    # File.delete( @filepath ) if File.exists?( @filepath )
    if File.exists?( @filepath )
      puts "234 the file at #{@filepath} EXISTS"
      File.delete( @filepath ) 
    end
    
    
    
    workbook = WriteExcel.new( @filepath )
      
    worksheet = workbook.add_worksheet
    
    
    row = 0 
    
   
    # col 1 
    worksheet.set_column(LOCKED_SAVINGS_NUMBER_COLUMN, LOCKED_SAVINGS_NUMBER_COLUMN,  20)
    # col 2
    worksheet.set_column(LOCKED_SAVINGS_MEMBER_ID, LOCKED_SAVINGS_MEMBER_ID,  20)
    # col 3
    worksheet.set_column(LOCKED_SAVINGS_MEMBER_NAME, LOCKED_SAVINGS_MEMBER_NAME,  30)
    # col 4
    worksheet.set_column(LOCKED_SAVINGS_TRANSACTION_DATE, LOCKED_SAVINGS_TRANSACTION_DATE,  20)
    # col 5
    worksheet.set_column(LOCKED_SAVINGS_TRANSACTION_TYPE, LOCKED_SAVINGS_TRANSACTION_TYPE,  20)
    # col 6,7,8
    worksheet.set_column(LOCKED_SAVINGS_TRANSACTION_AMOUNT, LOCKED_SAVINGS_LAST_GROUP_NAME,  30)
    
    
    worksheet.write(0, LOCKED_SAVINGS_NUMBER_COLUMN  , 'NO')
    worksheet.write(0, LOCKED_SAVINGS_MEMBER_ID  , 'Member ID')
    worksheet.write(0, LOCKED_SAVINGS_MEMBER_NAME  , 'Member Name')
    worksheet.write(0, LOCKED_SAVINGS_TRANSACTION_DATE  , 'Tanggal Transaksi')
    worksheet.write(0, LOCKED_SAVINGS_TRANSACTION_TYPE  , 'Tipe Transaksi')
    worksheet.write(0, LOCKED_SAVINGS_TRANSACTION_AMOUNT  , 'Jumlah')
    worksheet.write(0, LOCKED_SAVINGS_LAST_GROUP_NO  , 'Last Group Loan No')
    worksheet.write(0, LOCKED_SAVINGS_LAST_GROUP_NAME  , 'Last Group Loan Name')
=begin
result = TransactionData.eager_load(:transaction_data_details => [:account]).where{
    (is_confirmed.eq true ) & 
    (transaction_datetime.gte start_date) & 
    ( transaction_datetime.lt end_date )
  }.order("transaction_datetime DESC").limit(1000).map{|x| x.transaction_datetime}
  
  start
=end 
    
    
    row += 1
    entry_number  = 1 
    SavingsEntry.eager_load(:member).where{
        (is_confirmed.eq true ) & 
        (savings_status.eq SAVINGS_STATUS[:locked]) &
        (confirmed_at.gte start_date) & 
        ( confirmed_at.lt end_date )
      }.order("member_id ASC, confirmed_at ASC").find_each do |s_e|
      member = s_e.member 
      next if member.nil?
      last_glm = member.group_loan_memberships.eager_load(:group_loan).order("group_loan_memberships.id DESC").first
      
      last_group_loan = nil 
    
      last_group_loan = last_glm.group_loan  if not last_glm.nil? 
      
      
      worksheet.write(row, LOCKED_SAVINGS_NUMBER_COLUMN  ,  entry_number )
      worksheet.write(row, LOCKED_SAVINGS_MEMBER_ID  , member.id_number )
      worksheet.write(row, LOCKED_SAVINGS_MEMBER_NAME  , member.name  )
      
      worksheet.write(row, LOCKED_SAVINGS_TRANSACTION_DATE  , s_e.confirmed_at )
      
      
      
      
      if s_e.direction == FUND_TRANSFER_DIRECTION[:incoming]
        worksheet.write(row, LOCKED_SAVINGS_TRANSACTION_TYPE  , "Penambahan")
      elsif s_e.direction == FUND_TRANSFER_DIRECTION[:outgoing]
        worksheet.write(row, LOCKED_SAVINGS_TRANSACTION_TYPE  , "Penarikan" )
      end
      
      worksheet.write(row, LOCKED_SAVINGS_TRANSACTION_AMOUNT  ,  s_e.amount )
      
      if last_group_loan.nil?
        worksheet.write(row, LOCKED_SAVINGS_LAST_GROUP_NO  ,  "N/A" )
        worksheet.write(row, LOCKED_SAVINGS_LAST_GROUP_NAME  ,  "N/A")
      else
        worksheet.write(row, LOCKED_SAVINGS_LAST_GROUP_NO  ,  last_group_loan.group_number )
        worksheet.write(row, LOCKED_SAVINGS_LAST_GROUP_NAME  ,  last_group_loan.name )
      end
      
      row += 1
      entry_number += 1 
    end
    
    workbook.close
    
    
=begin
  UPLOADING DATA TO THE S3
=end

    puts "Gonna upload to s3!!!"

    connection = Fog::Storage.new({
      :provider                 => 'AWS',
      :aws_access_key_id        => Figaro.env.s3_key ,
      :aws_secret_access_key    => Figaro.env.s3_secret 
    })
    directory = connection.directories.get( Figaro.env.s3_bucket  ) 
    
    file = directory.files.create(
      :key    => @awesome_filename,
      :body   => File.open( @filepath ),
      :public => true
    )
    
    @public_url = file.public_url 
    puts "The public url: #{@public_url}"
    
    
    
    now = DateTime.now
    
    mail(:to => mail_list, :subject => "Locked Savings Report #{now.year}-#{now.month}-#{now.day}") 
  end


  def send_member_data_download_link
    content = 'awesome banzai'
    mail_list = ["w.yunnal@gmail.com", "isabella.harefa@gmail.com"]
    
    
    
    @objects_length = Member.count


   
     
    @awesome_filename = "MemberData_#{DateTime.now}.xls"
    @filepath = "#{Rails.root}/tmp/" + @awesome_filename
    
     
    # File.delete( @filepath ) if File.exists?( @filepath )
    if File.exists?( @filepath )
      puts "234 the file at #{@filepath} EXISTS"
      File.delete( @filepath ) 
    end
    
    
    
    workbook = WriteExcel.new( @filepath )
      
    worksheet = workbook.add_worksheet
    
    
    row = 0 
    
    worksheet.set_column(0, 0,  10) # Column  A   width set to 20
    
    worksheet.set_column(1, 6,  20)
    
    
    worksheet.write(0, 0  , 'NO')
    worksheet.write(0, 1  , 'No Kelompok')
    worksheet.write(0, 2  , 'Nama Kelompok')
    worksheet.write(0, 3  , 'Nama Member')
    worksheet.write(0, 4  , 'Id Member')
    worksheet.write(0, 5  , 'Kelurahan')
    worksheet.write(0, 6  , 'RW')
=begin
result = TransactionData.eager_load(:transaction_data_details => [:account]).where{
    (is_confirmed.eq true ) & 
    (transaction_datetime.gte start_date) & 
    ( transaction_datetime.lt end_date )
  }.order("transaction_datetime DESC").limit(1000).map{|x| x.transaction_datetime}
=end 
    
    
    row += 1
    entry_number  = 1 
    Member.order("id_number ASC").find_each do |member|
        
      active_glm = member.group_loan_memberships.where(:is_active => true).order("id DESC").first
      
      worksheet.write(row, 0  ,  entry_number )

      group_name = "N/A"
      group_no = "N/A"

      if not active_glm.nil?
        group_name = active_glm.group_loan.name
        group_no = active_glm.group_loan.group_number
      end

      worksheet.write(row, 1  , group_no )
      worksheet.write(row, 2  , group_name )
      worksheet.write(row, 3  , member.name )
      worksheet.write(row, 4  , member.id_number )
      worksheet.write(row, 5  , member.village )
      worksheet.write(row, 6  , member.rw )
    
    
      length = 0 
    
      row += length   + 1 
      entry_number += 1
    end
    
    workbook.close
    
    
=begin
  UPLOADING DATA TO THE S3
=end

    puts "Gonna upload to s3!!!"

    connection = Fog::Storage.new({
      :provider                 => 'AWS',
      :aws_access_key_id        => Figaro.env.s3_key ,
      :aws_secret_access_key    => Figaro.env.s3_secret 
    })
    directory = connection.directories.get( Figaro.env.s3_bucket  ) 
    
    file = directory.files.create(
      :key    => @awesome_filename,
      :body   => File.open( @filepath ),
      :public => true
    )
    
    @public_url = file.public_url 
    puts "The public url: #{@public_url}"
    
    
    
    now = DateTime.now
    
    mail(:to => mail_list, :subject => "Member report #{now.year}-#{now.month}-#{now.day}") 
  end
  
  


=begin
  start_date = DateTime.new(2011,1,1,0,0,0)
  end_date = DateTime.new(2014,12,30,0,0,0)
  email = "w.yunnal@gmail.com"


  example use case:
  # with delayed_job
  Notifier.delay.signup(@user)
  UserMailer.delay.send_membership_and_locked_savings_summary_download_link( start_date, end_date, email )  
=end
  def send_membership_and_locked_savings_summary_download_link( start_date, end_date, email )  
    content = 'membership + locked savings'
    mail_list = ["w.yunnal@gmail.com"]
    mail_list << email 


    @awesome_start_date = "all date"
    @awesome_end_date = "all date" 


=begin
SavingsEntry.where{
  (is_confirmed.eq true ) & 
  (savings_status.eq SAVINGS_STATUS[:locked])
}.count
=end


    




    @awesome_filename = "LockedSavings-#{start_date.to_date}_to_#{end_date.to_date}.xls"
    @filepath = "#{Rails.root}/tmp/" + @awesome_filename


    # File.delete( @filepath ) if File.exists?( @filepath )
    if File.exists?( @filepath )
      puts "234 the file at #{@filepath} EXISTS"
      File.delete( @filepath ) 
    end



    workbook = WriteExcel.new( @filepath )

    worksheet = workbook.add_worksheet


    row = 0 
 
    worksheet.set_column(0, 0,  20)
    worksheet.set_column(1, 4,  30)

    worksheet.write(0, 0  , 'NO')
    worksheet.write(0, 1  , 'Member ID')
    worksheet.write(0, 2  , 'Member Name')
    worksheet.write(0, 3  , 'Membership Savings')
    worksheet.write(0, 4  , 'Locked Savings')

    
    zero_amount = BigDecimal("0")
    
    @objects_length = Member.where{
      (total_locked_savings_account.gt zero_amount) | 
      (total_membership_savings.gt zero_amount) 
    }.count
    
    
    
    row += 1
    entry_number  = 1 
    
    
    Member.where{
      (total_locked_savings_account.gt zero_amount) |  
      (total_membership_savings.gt zero_amount) 
    }.find_each do |member|
      
      worksheet.write(row, 0  ,  entry_number )
      worksheet.write(row, 1  , member.id_number )
      worksheet.write(row, 2  , member.name  )

      worksheet.write(row, 3  , member.total_membership_savings.to_s )
      worksheet.write(row, 4  , member.total_locked_savings_account.to_s )
      
      row += 1
      entry_number += 1
    end
    
    workbook.close


=begin
  UPLOADING DATA TO THE S3
=end

    puts "Gonna upload to s3!!!"

    connection = Fog::Storage.new({
      :provider                 => 'AWS',
      :aws_access_key_id        => Figaro.env.s3_key ,
      :aws_secret_access_key    => Figaro.env.s3_secret 
    })
    directory = connection.directories.get( Figaro.env.s3_bucket  ) 

    file = directory.files.create(
      :key    => @awesome_filename,
      :body   => File.open( @filepath ),
      :public => true
    )

    @public_url = file.public_url 
    puts "The public url: #{@public_url}"



    now = DateTime.now

    mail(:to => mail_list, :subject => "Member Savings Summary #{now.year}-#{now.month}-#{now.day}") 
  end

  def send_slip_gaji(data)

    #   0      nama : ARIanto WIbowo
#  1 email : arie@ssd.dnet.net.id
#  2 tanggal bergabung : 3/29/2011
#  3 jabatan: Staff IT
#  4 lokasi: IT JKT
#  5 rekening_bca:  
#  6 jumlah hari kerja: 26
#  7 cuti: 1
#  8 absen: 0
#  9 gaji pokok: 
#  10 tunjangan masa kerja:  
#  11 tunjangan hadir:  
#  12 tunjangan transport:  
#  13 tunjangan makan:  
#  14 potongan asuransi: 0.0
#  15 potongan koperasi:  
# 16 Total:  

    @data = data
    target = ["w.yunnal@gmail.com"]
    target << @data[1]
    # target << email 
    

   
     
#     @awesome_filename = "slip_gaji-#{data[0]}-#{DateTime.now}.xls"
#     @filepath = "#{Rails.root}/tmp/" + @awesome_filename
    
     
#     # File.delete( @filepath ) if File.exists?( @filepath )
#     if File.exists?( @filepath )
#       puts "234 the file at #{@filepath} EXISTS"
#       File.delete( @filepath ) 
#     end
    
    
    
#     workbook = WriteExcel.new( @filepath )
      
#     worksheet = workbook.add_worksheet
    
    
#     row = 0 
    
#     worksheet.set_column(0, 3,  20) 
    

#        #   0      nama : ARIanto WIbowo
# #  1 email : arie@ssd.dnet.net.id
# #  2 tanggal bergabung : 3/29/2011
# #  3 jabatan: Staff IT
# #  4 lokasi: IT JKT


    
#     worksheet.write(0, 0  , 'PT Solusi Sentral Data')
#     worksheet.write(1, 0  , 'Slip Gaji')

#     worksheet.write(4, 0  , 'Nama Karyawan')
#     worksheet.write(4, 1  , data[0])
#     worksheet.write(5, 0  , 'Department')
#     worksheet.write(5, 1  , data[4])
#     worksheet.write(6, 0  , 'Jabatan')
#     worksheet.write(6, 1  , data[3])
#     worksheet.write(7, 0  , 'Tanggal Masuk')
#     worksheet.write(7, 1  , data[2])




# #  6 jumlah hari kerja: 26
# #  7 cuti: 1
# #  8 absen: 0
#     worksheet.write(4, 2  , 'Jumlah hari kerja')
#     worksheet.write(4, 3  , data[6])
#     worksheet.write(5, 2  , 'Cuti')
#     worksheet.write(5, 3  , data[1])
#     worksheet.write(6, 2  , 'Absen')
#     worksheet.write(6, 3  , data[0])





 

#     worksheet.write(10, 0  , 'Gaji Pokok')
#     worksheet.write(10, 1  , data[9] ) 
#     worksheet.write(11, 0  , 'Tunjangan Makan')
#     worksheet.write(11, 1  , data[13])
#     worksheet.write(12, 0  , 'Tunjangan Transport')
#     worksheet.write(12, 1  , data[12])
#     worksheet.write(13, 0  , 'Tunjangan Hadir Penuh')
#     worksheet.write(13, 1  , data[11])
#     worksheet.write(14, 0  , 'Tunjangan Masa Kerja')
#     worksheet.write(14, 1  , data[10])

#     worksheet.write(15, 0  , 'Potongan Asuransi')
#     worksheet.write(15, 1  ,  data[14])
#     worksheet.write(16, 0  , 'Potongan Koperasi')
#     worksheet.write(16, 1  ,  data[15])

#     worksheet.write(18, 0  , 'Gaji Diterima')
#     worksheet.write(18, 1  ,  data[16])


#     worksheet.write(19, 0  , 'Pembayaran')
#     worksheet.write(19, 1  , 'Transfer')

#     worksheet.write(20, 0  , 'Rekening')
#     worksheet.write(20, 1  , data[5])

    
#     workbook.close
    
     
     
    
#     attachments[ "#{@awesome_filename}"] = File.read(@filepath )
    mail(:to => target, :subject => "SlipGaji #{DateTime.now}")
  end
    
    
end

