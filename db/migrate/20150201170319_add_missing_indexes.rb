class AddMissingIndexes < ActiveRecord::Migration
  def change
    add_index :valid_combs, :account_id
    add_index :valid_combs, :closing_id
    add_index :valid_comb_savings_entries, :member_id
    add_index :transaction_data_details, :account_id
    add_index :transaction_data_details, :transaction_data_id
    add_index :savings_entries, [:savings_source_id, :savings_source_type], :name => 'savings_entry_source_index'
    add_index :savings_entries, [:financial_product_id, :financial_product_type], :name => 'financial_product_source_index'
    add_index :savings_entries, :member_id
    add_index :group_loan_weekly_uncollectibles, :group_loan_membership_id, :name => 'glwu_glm'
    add_index :group_loan_weekly_uncollectibles, :group_loan_id, :name => 'glwu_gl'
    add_index :group_loan_weekly_uncollectibles, :group_loan_weekly_collection_id, :name => 'glwu_glwc'
    add_index :group_loan_disbursements, :group_loan_id
    add_index :group_loan_disbursements, :group_loan_membership_id
    add_index :deceased_clearances, :member_id
    add_index :deceased_clearances, [:financial_product_id, :financial_product_type], :name => 'deceased_clearance_source_index'
    add_index :group_loan_memberships, :member_id
    add_index :group_loan_memberships, :group_loan_id
    add_index :group_loan_memberships, :group_loan_product_id
    add_index :group_loan_memberships, [:group_loan_id, :member_id]
    add_index :group_loan_weekly_collection_voluntary_savings_entries, :group_loan_membership_id, :name => 'glwc_vse_glm'
    add_index :group_loan_weekly_collection_voluntary_savings_entries, :group_loan_weekly_collection_id, :name => 'glwc_vse_glwc'
    add_index :group_loan_premature_clearance_payments, :group_loan_id, :name => 'gl_pcp_gl'
    add_index :group_loan_premature_clearance_payments, :group_loan_membership_id, :name => 'gl_pcp_glm'
    add_index :group_loan_premature_clearance_payments, :group_loan_weekly_collection_id, :name => 'gl_pcp_glwc'
    add_index :transaction_activities, [:transaction_source_id, :transaction_source_type], :name => 'transaction_activity_source_index'
    add_index :group_loan_run_away_receivables, :group_loan_membership_id, :name => 'gl_rar_glm'
    add_index :group_loan_run_away_receivables, :group_loan_weekly_collection_id, :name => 'gl_rar_glwc'
    add_index :group_loan_run_away_receivables, :member_id, :name => 'gl_rar_m'
    add_index :group_loan_run_away_receivables, :group_loan_id, :name => 'gl_rar_gl'
    add_index :users, :role_id
    add_index :accounts, :parent_id
    add_index :memorial_details, :memorial_id
    add_index :memorial_details, :account_id
    add_index :group_loan_weekly_payments, :group_loan_membership_id, :name => 'gl_wp_glm'
    add_index :group_loan_weekly_payments, :group_loan_id, :name => 'gl_wp_gl'
    add_index :group_loan_weekly_payments, :group_loan_weekly_collection_id, :name => 'gl_wp_glwc'
    add_index :group_loan_weekly_collections, :group_loan_id
  end
end
