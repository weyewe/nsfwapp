require 'rubygems'
require 'pg'
require 'active_record'
require 'csv'

class MigrateWeeklyCollection


=begin
Column:
1. savings_status
2. amount 
3. direction (in / out?)
4. Member
=end

  def perform_weekly_voluntary_savings_posting( group_loan, gl_wc)
    if gl_wc.group_loan_weekly_collection_voluntary_savings_entries.each do |glwc_vse|

      AccountingService::WeeklyCollectionVoluntarySavings.create_journal_posting(
      group_loan,
      gl_wc,
      glwc_vse
      )

    end
  end
  
  
  

  def perform_awesome(group_loan, gl_wc)
    
      
      
      

      # paying_member                                                = (active_glm_id_list + run_away_glm_id_list).uniq - uncollectible_glm_id_list

      

      
    end
  end

  def perform_premature_clearance_posting( group_loan, gl_wc)
    gl_wc.group_loan_premature_clearance_payments.each do |x|

      # deposit payment
      deposit_amount                                               = x.premature_clearance_deposit_amount

      if deposit_amount != BigDecimal("0")
        member                                                     = x.group_loan_membership.member 
        AccountingService::PrematureClearance.create_premature_clearance_deposit_posting(group_loan,
        member, 
        x,
        deposit_amount)
      end



      # remaining weeks payment 
      glp                                                          = x.group_loan_membership.group_loan_product
      total_principal                                              = glp.principal * x.total_unpaid_week
      total_interest                                               = glp.interest * x.total_unpaid_week
      total_compulsory_savings                                     = glp.interest * x.total_unpaid_week


      member                                                       = x.group_loan_membership.member 

      AccountingService::PrematureClearance.create_premature_clearance_posting(
      group_loan,
      member, 
      total_principal,
      total_interest, 
      total_compulsory_savings,
      x
      )


    end
  end
  
  def monkey_king(group_loan, gl_wc)
    uncollectible_glm_id_list = gl_wc.uncollectible_group_loan_membership_id_list
    active_glm_id_list        = gl_wc.active_group_loan_memberships.map {|x| x.id }
    run_away_glm_id_list      = group_loan.group_loan_memberships.joins(:group_loan_run_away_receivable).
                        where{
                          (deactivation_case.eq  GROUP_LOAN_DEACTIVATION_CASE[:run_away] ) & 
                          (group_loan_run_away_receivable.payment_case.eq GROUP_LOAN_RUN_AWAY_RECEIVABLE_CASE[:weekly])
                          }.map{|x| x.id }


    active_glm_id_list       = active_glm_id_list - uncollectible_glm_id_list
    run_away_glm_id_list     = run_away_glm_id_list - uncollectible_glm_id_list
                             
                             
    total_main_cash          = BigDecimal("0")
    total_interest_revenue   = BigDecimal("0")
    total_principal          = BigDecimal("0")
    total_compulsory_savings = BigDecimal("0")
    
    GroupLoanMembership.
            where(:id  =>  active_glm_id_list + run_away_glm_id_list ).
            joins(:group_loan_product).each do |glm|
      total_interest_revenue +=   glm.group_loan_product.interest 
      total_principal +=         glm.group_loan_product.principal 
      total_compulsory_savings += glm.group_loan_product.compulsory_savings
    end
    
    AccountingService::WeeklyPayment.create_journal_posting(
        group_loan,
        gl_wc,
        total_compulsory_savings ,
        total_principal,
        total_interest_revenue
    )
  end
  
  def summation
  end
  
  


  def perform

    total = GroupLoan.where(
    :is_loan_disbursed   => true 
    ).count
    
    counter = 1 
    
    GroupLoan.where(
    :is_loan_disbursed   => true 
    ).find_each do |group_loan|
      puts "group_loan #{counter}/ #{total}"

      group_loan.group_loan_weekly_collections.where(:is_collected => true, :is_confirmed => true ).each do |gl_wc|


        # perform posting for group_loan_weekly_collection voluntary-savings_entries
        self.delay.perform_weekly_voluntary_savings_posting( group_loan, gl_wc)

        # PERFORM POSTING FOR WEEKLY PAYMENT 
        self.delay.monkey_king(group_loan, gl_wc)
        # self.delay.perform_weekly_payment_posting(group_loan, gl_wc)


        # PERFORM POSTING FOR PREMATURE CLEARANCE
        self.delay.perform_premature_clearance_posting( group_loan, gl_wc)


      end

      counter += 1 
    end




  end
end

=begin
[:perform_weekly_voluntary_savings_posting, :perform_premature_clearance_posting, :perform, :blank?, :present?, :presence, :acts_like?, :duplicable?, :deep_dup, :try, :try!, :in?, :to_param, :to_query, :instance_values, :instance_variable_names, :to_json, :with_options, :psych_to_yaml, :to_yaml_properties, :to_yaml, :html_safe?, :`, :as_json, :is_haml?, :pretty_print, :pretty_print_cycle, :pretty_print_instance_variables, :pretty_print_inspect, :require_or_load, :require_dependency, :load_dependency, :load, :require, :unloadable, :delay, :__delay__, :send_later, :send_at, :nil?, :===, :=~, :!~, :eql?, :hash, :<=>, :class, :singleton_class, :clone, :dup, :initialize_dup, :initialize_clone, :taint, :tainted?, :untaint, :untrust, :untrusted?, :trust, :freeze, :frozen?, :to_s, :inspect, :methods, :singleton_methods, :protected_methods, :private_methods, :public_methods, :instance_variables, :instance_variable_get, :instance_variable_set, :instance_variable_defined?, :instance_of?, :kind_of?, :is_a?, :tap, :send, :public_send, :respond_to?, :respond_to_missing?, :extend, :display, :method, :public_method, :define_singleton_method, :object_id, :to_enum, :enum_for, :gem, :silence_warnings, :enable_warnings, :with_warnings, :silence_stderr, :silence_stream, :suppress, :capture, :silence, :quietly, :class_eval, :psych_y, :debugger, :breakpoint, :suppress_warnings, :pretty_inspect, :==, :equal?, :!, :!=, :instance_eval, :instance_exec, :__send__, :__id__] 
=end