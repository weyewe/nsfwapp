module AccountingService
  class Utility
    def self.extract_appendix( group_loan) 
      first_group_loan_product_name = group_loan.group_loan_memberships.first.group_loan_product.name
      appendix  = "N/A"
      appendix = "NS" if first_group_loan_product_name =~ /^NS/i 
      appendix = "S" if first_group_loan_product_name =~ /^S/i 

      return appendix
    end

  end
end
