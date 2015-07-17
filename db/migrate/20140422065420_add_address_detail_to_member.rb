class AddAddressDetailToMember < ActiveRecord::Migration
  def change
    add_column :members, :rt, :integer
    add_column :members, :rw, :integer 
    add_column :members, :village, :string 
  end
end
