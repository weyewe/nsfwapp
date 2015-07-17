class WeeklyCollectionPdf < Prawn::Document
  
  # def initialize(invoice, view)
  #   super()
  #   @sales_order = invoice
  #   @view = view
  #   text "Invoice #{@sales_order.printed_sales_invoice_code}"
  # end
  
  
  
  
  # 595.28 x 841.89
  def initialize(object , view)
    super(:size => "A4", :page_layout => :landscape)  #[width,length]
    @page_width = 841
    @page_length = 595
    @object = object
    @group_loan = object.group_loan
    @glwc_id_list = []
    @group_loan.group_loan_weekly_collections.where{
        (week_number.lte object.week_number )
      }.each {|x| @glwc_id_list << x.id }

    @active_glm_list = @object.active_group_loan_memberships.joins(:group_loan_product).order("id ASC")
    @view = view
    @glwc_attendance_list  = @object.group_loan_weekly_collection_attendances
    @glwc_voluntary_savings_list = @object.group_loan_weekly_collection_voluntary_savings_entries
  
    # page_size  [684, 792]
    # font("Helvetica")
    
    # text "My report caption", :size => 18, :align => :right
    # move_down font.height * 2
    
    
    title 
    move_down 20 
    company_customer_details 
    
    subscription_details
    # subscription_details
    # subscription_amount
    # regards_message
    
    page_numbering 
  end
   
   
  def title
    bounding_box( [150,cursor], :width => @page_width - 300) do
      text "Laporan Konfirmasi Setoran", 
          :size => 15, 
          :align => :center 
          
      datetime = DateTime.now
      text "Print Date: #{datetime.day}/#{datetime.month}/#{datetime.year}", 
          :size => 12, 
          :align => :center
      text "Dalam ribuan", 
          :size => 12, 
          :align => :center
    end 
  end
  
  def company_customer_details
    gap = 0 
    box_separator = 20 
    
    half_page = @page_width/2
    width = half_page - box_separator
    
    bounding_box( [0,cursor], :width => @page_width) do
      bounding_box([gap, bounds.top - gap], :width => width) do 
        text  "No & Nama Kelompok: [#{@group_loan.group_number}] - #{@group_loan.name}"
        text  "Nama PKP: "
        text  "Setoran Ke: #{@object.week_number}"
      end
      
     
      bounding_box([half_page + box_separator, bounds.top - gap], :width => width) do 
        text "Hari Setor"
        text "Tanggal Setor"
        text "Catatan"
      end 
    end
  end
   
  def thanks_message
    move_down 80
    text "Hello Customer Name" #"Hello #{@sales_order.customer.profile.first_name.capitalize},"
    move_down 15
    text "Thank you for your order.Print this receipt as confirmation of your order.",
    :indent_paragraphs => 40, :size => 13
  end
   
  def subscription_date
    move_down 40
    text "Subscription start date:
   #{@sales_order.created_at.strftime("%d/%m/%Y")} ", :size => 13
    move_down 20
    text "Subscription end date : 
   #{@sales_order.updated_at.strftime("%d/%m/%Y")}", :size => 13
  end
   
  def subscription_details
    move_down 40
    
    # table subscription_item_rows , :position => :center , :width => @page_width -100 do
    table subscription_item_rows , :position => :left do
      row(0).font_style = :bold

      columns(0..10).align = :left
      self.header = true
      # total is 792
      self.column_widths = { 
          0 => 30 , #  entry number  
          1 => 80,  # Nama member
          2 => 50, # No member
          3 => 80, # Jumlah Pinjaman
          4 => 80, # setoran mingguan
          5 => 30 , #  Bayar
          6 => 30,  # Tepat Waktu
          7 => 50, # Menabung minggu lalu
          8 => 50, # Ambil Tab Minggu Lalu
          9 => 100, # Saldo sisa tabungan pribadi
          10 => 50, # Sisa pinjaman
      }
      # self.cell_style = {
      #   :minimum_height => 50
      # }
      row(0).height = 40
    end
    
    
    # table subscription_item_rows do
    #   row(0).font_style = :bold
    #   columns(1..3).align = :right
    #   self.header = true
    #   self.column_widths = {0 => 100, 1 => 200, 2 => 100, 3 => 100, 4 => 100}
    # end
  end
   
  
   
  def subscription_item_rows
    count = 0
    total_price_in_sales_order = BigDecimal("0")
    
    header = [["No", "Nama", "ID", "Jumlah Pinjaman", "Setoran Mingguan",
                "Bayar", "Tepat Waktu", "Menabung minggu lalu", "Ambil Tab minggu lalu", 
                "Saldo sisa tabungan pribadi", "Sisa Cicil", "Total DTR", "Total Telat"

      ]] 
    body = [] 
    
    (@active_glm_list).map do |active_glm|
      count = count + 1 
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

      body << [ 
            "#{count}",
            "#{member.name}",
            "#{member.id_number}",
            "#{ total_principal_adjusted }",
            "#{ total_installment_adjusted }",
            "#{payment_status}", # bayar
            "#{attendance_status}", #  tepat waktu
            "#{savings_addition_adjusted}", # menabung minggu lalu
            "#{savings_withdrawal_adjusted}", # ambil tab minggu lalu
            "#{ remaining_savings_adjusted }" , # saldo sisa tabungan pribadi
            "#{remaining_amount_adjusted}",  # sisa pinjaman
            "#{total_dtr}",
            "#{total_telat}"
       ]
    end  
    
    # footer = [[
    #   "",
    #   " ", '',
    # "Total  ",  
    # "#{precision(total_price_in_sales_order)}"
    # ]]
    
    return header + body  #+ footer 
  end
  
  def make_cell_image_placeholder
    make_cell("", {
      :height => 100
    })
  end
   
  def precision(num)
    @view.number_with_precision(num, :precision => 2)
  end
   
  def regards_message
    move_down 50
    # text "Thank You," ,:indent_paragraphs => 400
    move_down 6
    # text "XYZ",
    # :indent_paragraphs => 370, :size => 14, style:  :bold
  end
  
  def page_numbering
    string = "<page> / <total>" # Green page numbers 1 to 7
    options = {
      :at => [bounds.right - 150, bounds.top], 
      :width => 150, :align => :right, 
      :start_count_at => 1 
    } 
    number_pages string, options
  end
 
end