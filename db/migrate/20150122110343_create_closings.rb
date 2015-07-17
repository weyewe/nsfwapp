class CreateClosings < ActiveRecord::Migration
  def change
    create_table :closings do |t|
      
      t.boolean :is_first_closing, :default => false 
      
      t.datetime :start_period # byproduct
      t.datetime :end_period
      
      t.string :description 
      
      t.decimal :expense_adjustment_amount, :default        => 0,  :precision => 14, :scale => 2
      
      t.integer :expense_adjustment_case 
      
      t.decimal :revenue_adjustment_amount, :default        => 0,  :precision => 14, :scale => 2
      t.integer :revenue_adjustment_case 
      
      t.decimal :net_earnings_amount, :default        => 0,  :precision => 14, :scale => 2
      t.integer :net_earnings_case 
      
      t.boolean :is_confirmed, :default => false
      t.datetime :confirmed_at 

      t.timestamps
    end
  end
end
