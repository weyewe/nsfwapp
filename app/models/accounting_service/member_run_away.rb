module AccountingService
  class MemberRunAway
    def MemberRunAway.create_bad_debt_allocation(group_loan, member, group_loan_membership, group_loan_weekly_collection,group_loan_run_away_receivable) 
      
      remaining_weeks = group_loan.number_of_collections - group_loan_weekly_collection.week_number + 1 
      remaining_principal = group_loan_membership.group_loan_product.principal * remaining_weeks 



      message = "Runaway Bad Debt Allowance: Group #{group_loan.name}, #{group_loan.group_number}, member: #{member.name}"

      ta = TransactionData.create_object({
        :transaction_datetime => group_loan_run_away_receivable.member.run_away_at,
        :description =>  message,
        :transaction_source_id => group_loan_run_away_receivable.id , 
        :transaction_source_type => group_loan_run_away_receivable.class.to_s ,
        :code => TRANSACTION_DATA_CODE[:group_loan_run_away_declaration],
        :is_contra_transaction => false 
      }, true )



      TransactionDataDetail.create_object(
        :transaction_data_id => ta.id,        
        :account_id          => Account.find_by_code(ACCOUNT_CODE[:pinjaman_sejahtera_bda_leaf][:code]).id      ,
        :entry_case          => NORMAL_BALANCE[:debit]     ,
        :amount              => remaining_principal,
        :description => message
      )

      TransactionDataDetail.create_object(
        :transaction_data_id => ta.id,        
        :account_id          => Account.find_by_code(ACCOUNT_CODE[:pinjaman_sejahtera_ar_leaf][:code]).id        ,
        :entry_case          => NORMAL_BALANCE[:credit]     ,
        :amount              => remaining_principal,
        :description => message
      )
      ta.confirm
    end
    
    def MemberRunAway.cancel_bad_debt_allocation(object)
    end
    
    def MemberRunAway.run_away_in_cycle_payment( group_loan_weekly_payment )
      current_week_number = group_loan_weekly_payment.week_number
      group_loan = group_loan_weekly_payment.group_loan 
      run_away_glm_id_list = GroupLoanMembership.where{
        (is_active.eq false) & 
        (deactivation_case.eq GROUP_LOAN_DEACTIVATION_CASE[:run_away] ) & 
        ( deactivation_week_number.lte current_week_number)
      }.collect {|x| x.id }

      GroupLoanRunAwayReceivable.joins(:group_loan_membership => [:group_loan_product, :member]).where(
          :group_loan_membership_id => run_away_glm_id_list, 
          :payment_case => GROUP_LOAN_RUN_AWAY_RECEIVABLE_CASE[:weekly] ).each do |x|
        member  = x.group_loan_membership.member 
        principal = x.group_loan_membership.group_loan_product.principal
        message = "Runaway Weekly Bad Debt clearance: Group #{group_loan.name}, #{group_loan.group_number}, member: #{member.name}"

        ta = TransactionData.create_object({
          :transaction_datetime => group_loan_weekly_payment.collected_at,
          :description =>  message,
          :transaction_source_id => group_loan_weekly_payment.id , 
          :transaction_source_type => group_loan_weekly_payment.class.to_s ,
          :code => TRANSACTION_DATA_CODE[:group_loan_run_away_in_cycle_clearance],
          :is_contra_transaction => false 
        }, true )



        TransactionDataDetail.create_object(
          :transaction_data_id => ta.id,        
          :account_id          => Account.find_by_code(ACCOUNT_CODE[:pinjaman_sejahtera_bda_leaf][:code]).id      ,
          :entry_case          => NORMAL_BALANCE[:credit]     ,
          :amount              => principal,
          :description => message
        )

        TransactionDataDetail.create_object(
          :transaction_data_id => ta.id,        
          :account_id          => Account.find_by_code(ACCOUNT_CODE[:pinjaman_sejahtera_ar_leaf][:code]).id        ,
          :entry_case          => NORMAL_BALANCE[:debit]     ,
          :amount              => principal,
          :description => message
        )
        ta.confirm
      end
    end
    
    def MemberRunAway.cancel_run_away_in_cycle_payment(group_loan_weekly_payment)
      ta = TransactionData.where({
        :transaction_source_id => group_loan_weekly_payment.id , 
        :transaction_source_type => group_loan_weekly_payment.class.to_s ,
        :code => TRANSACTION_DATA_CODE[:group_loan_run_away_in_cycle_clearance],
        :is_contra_transaction => false 
      } ).order("id DESC").first


      ta.create_contra_and_confirm if not ta.nil?
    end

  end
end
