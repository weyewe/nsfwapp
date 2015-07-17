class CreateMembers < ActiveRecord::Migration
  def change
    create_table :members do |t|
      
      t.string :name 
      t.text :address 
      
      t.string :id_number 
      
      t.decimal :total_savings_account , :default        => 0,  :precision => 12, :scale => 2
      
      t.boolean :is_deceased, :default => false
      t.datetime :deceased_at  
      
      t.boolean :is_run_away, :default => false 
      t.datetime :run_away_at 
      
      t.timestamps
    end
  end
end
