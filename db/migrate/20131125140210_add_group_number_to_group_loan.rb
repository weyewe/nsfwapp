class AddGroupNumberToGroupLoan < ActiveRecord::Migration
  def change
    add_column :group_loans,  :group_number , :string
  end
end
