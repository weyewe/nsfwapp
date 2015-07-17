require 'csv'
require 'writeexcel'
# require 'stringio' 

class TransactionDatasController < ApplicationController
  
  
  def download_xls
    
    start_date =  parse_date( params[:start_date] )
    end_date =  parse_date( params[:end_date] )
    @objects = TransactionData.eager_load(:transaction_data_details => [:account]).where{
      (is_confirmed.eq true ) & 
      (transaction_datetime.gte start_date) & 
      ( transaction_datetime.lt end_date )
      }.order("transaction_datetime DESC")


    puts "1111 length: #{@objects.length}"
    data_array = @objects 
     
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
    data_array.each do |transaction|
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
    
    send_file "#{@filepath}", :type => "application/vnd.ms-excel", :filename => "#{@awesome_filename}"#, :stream => false
    
    if File.exists?( @filepath )
      puts "234 the file at #{@filepath} EXISTS"
      # File.delete( @filepath ) 
    end
    
    # File.delete("#{@awesome_filename}") 
    # FileUtils.rm(@filepath)d
    
    
  end
end
