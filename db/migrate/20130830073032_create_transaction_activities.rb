class CreateTransactionActivities < ActiveRecord::Migration
  def change
    create_table :transaction_activities do |t|
      t.integer :transaction_source_id 
      t.string :transaction_source_type 
      
      
      t.integer :fund_case # FUND_TRANSFER_CASE[:cash] or FUND_TRANSFER_CASE[:savings]
      t.decimal :amount , :default        => 0,  :precision => 10, :scale => 2
      t.integer :direction  
      
      t.decimal :savings, :default        => 0,  :precision => 10, :scale => 2
      t.integer :savings_direction
      
      t.integer :office_id 
      t.integer :member_id

      t.timestamps
    end
  end
end
