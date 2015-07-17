class CreateGroupLoans < ActiveRecord::Migration
  def change
    create_table :group_loans do |t|
      t.string :name  
      t.integer :number_of_meetings  # meetings is not linked with weekly installment
      t.integer :number_of_collections
      # meeting is education session 
      
      t.boolean :is_started, :default => false 
      t.datetime :started_at  
      
      # not really necessary. can be handled offline. 
      t.boolean :is_loan_disbursement_prepared, :default => false 
      
      t.boolean :is_loan_disbursed, :default => false 
      t.datetime :disbursed_at 
       
      t.boolean :is_closed, :default => false 
      t.datetime :closed_at 
      
      
      t.boolean :is_compulsory_savings_withdrawn, :default => false 
      t.datetime :compulsory_savings_withdrawn_at 
      
      t.integer :group_leader_id 
      
      
      
      # if there is member running away, do this shite. 
      # why do we need it? Won't it all be encompassed inside the default_payment? 
      
      # fuck it.. just leave it as it is.. I can't recall why it was coded 
      # t.decimal :run_away_amount_receivable, :default       => 0, :precision => 10, :scale => 2
      # t.decimal :run_away_amount_received , :default       => 0, :precision => 10, :scale => 2
      
      
      # these new shite... use it.
      # haven't been coded 
      t.decimal :premature_clearance_deposit, :default       => 0, :precision => 10, :scale => 2
      
      
      # compulsory savings returned  = total_compulsory_savings-pre_closure - 
      # => default amount + 
      # => remaining_premature_clearance_deposit
      
      
      t.decimal :total_compulsory_savings_pre_closure, :default       => 0, :precision => 10, :scale => 2
      
      
      # default amount: principal/loan portfolio at risk 
      # t.decimal :default_amount, :default       => 0, :precision => 10, :scale => 2
      
      t.decimal :bad_debt_allowance, :default       => 0, :precision => 10, :scale => 2
      t.decimal :bad_debt_expense, :default       => 0, :precision => 10, :scale => 2
      # t.decimal :recovered_default_amount, :default       => 0, :precision => 10, :scale => 2
      
      t.decimal :round_down_compulsory_savings_return_revenue, :default       => 0, :precision => 10, :scale => 2
      t.decimal :interest_revenue, :default       => 0, :precision => 10, :scale => 2
      
      
      t.timestamps
    end
  end
end
