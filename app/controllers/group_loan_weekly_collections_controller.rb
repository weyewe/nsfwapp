class GroupLoanWeeklyCollectionsController < ApplicationController

  
  

=begin
  PRINT SALES ORDER
=end
  def print_weekly_collection
    @object = GroupLoanWeeklyCollection.find_by_id params[:group_loan_weekly_collection_id]
    respond_to do |format|
      format.html # do
       #        pdf = SalesInvoicePdf.new(@sales_order, view_context)
       #        send_data pdf.render, filename:
       #        "#{@sales_order.printed_sales_invoice_code}.pdf",
       #        type: "application/pdf"
       #      end
      format.pdf do
        if @object and @object.is_confirmed 
          pdf = WeeklyCollectionPdf.new(@object, view_context)
          send_data pdf.render, filename:
            "group_#{@object.group_loan.name}_week_#{@object.week_number}.pdf",
            type: "application/pdf"
        else
          pdf = ErrorWeeklyCollectionPdf.new(@object, view_context)
          send_data pdf.render, filename:
            "please_confirm_collection.pdf",
            type: "application/pdf"
        end
        
      end
    end
  end
end
