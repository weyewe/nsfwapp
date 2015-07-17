class CreateAccounts < ActiveRecord::Migration
  def change
    create_table :accounts do |t|
      t.string :name
      t.integer :parent_id
      t.integer :lft
      t.integer :rgt
      t.integer :depth # this is optional.
      
      # we need total_amount
      # we need contra_account_id 
      # we need is_contra_account
      # we need parent_contra_account_id 
      # we need normal_balance  # debit or credit 
      
      t.decimal :amount , :default        => 0,  :precision => 14, :scale => 2 # 10*12 999 * 10^9
      
      t.boolean :is_contra_account, :default => false 
      
      t.integer :normal_balance , :default => NORMAL_BALANCE[:debit]
      
      t.integer :account_case , :default => ACCOUNT_CASE[:ledger]
      
      
      
      # master account 
      t.boolean :is_base_account, :default => false 
      # contra account will take place @balance sheet 
      
      t.string :code

      t.timestamps
    end
  end
end
