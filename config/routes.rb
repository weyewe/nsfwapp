NeoSikki::Application.routes.draw do
  devise_for :users 
  root :to => 'home#extjs' , :method => :get
  
  get 'group_loans/pending_fulfillment' => 'group_loans#download_pending', :as => :download_pending  
  get 'transaction_datas/download_xls' => 'transaction_datas#download_xls', :as => :download_transaction
  

  get 'print_weekly_collection/:group_loan_weekly_collection_id' => 
                    'group_loan_weekly_collections#print_weekly_collection' , :as => :print_weekly_collection


  namespace :api2 , constraints: { format: 'json' } do
    devise_for :users
    resources :sub_reddits
    resources :images
    
    resources :group_loan_weekly_collection_reports

    resources :membership_savings_reports 
    resources :savings_entry_reports

    get 'savings_entries_history/:id_number' => 'savings_entry_reports#member_history', :as => :get_member_savings_entries_history

    get 'get_total_members' => 'members#get_total_members', :as => :get_total_members

    resources :group_loans


    get 'pending_group_loans' => 'group_loans#pending_group_loans', :as => :pending_group_loans
    get 'disbursed_group_loans' => 'group_loans#disbursed_group_loans', :as => :disbursed_group_loans


    get 'first_uncollected_weekly_collection/:group_loan_id' => 
            'group_loan_weekly_collections#first_uncollected_weekly_collection', 
            :as => :first_uncollected_weekly_collection

    resources :group_loan_weekly_collection_attendances
    resources :group_loan_weekly_collection_voluntary_savings_entries 
    resources :transaction_datas

    resources :schwab_reports 
  end

  namespace :api do 
    devise_for :users
    
    
    post "download_transaction_data", :to => 'transaction_datas#download_transaction_data', :as => :download_tranasction_data
    post 'authenticate_auth_token', :to => 'sessions#authenticate_auth_token', :as => :authenticate_auth_token 
    put 'update_password' , :to => "passwords#update" , :as => :update_password
    
    get 'search_role' => 'roles#search', :as => :search_role 
    get 'search_group_loan_products' => 'group_loan_products#search', :as => :search_group_loan_product
    get 'search_group_loans' => 'group_loans#search', :as => :search_group_loan
    get 'search_members' => 'members#search', :as => :search_member
    get 'search_group_loan_memberships' => 'group_loan_memberships#search', :as => :search_group_loan_membership
    get 'search_group_loan_weekly_collections' => 'group_loan_weekly_collections#search', :as => :search_group_loan_weekly_collection
    

    get 'search_branches' => 'branches#search', :as => :search_branches


    resources :branches
    resources :employees
    resources :group_loan_weekly_collection_attendances 
    
    resources :app_users
    resources :members
    resources :group_loans 
    resources :group_loan_products
    resources :group_loan_memberships
    resources :group_loan_weekly_collections
    resources :group_loan_weekly_uncollectibles 
    resources :group_loan_premature_clearance_payments
    
    resources :deceased_clearances 
    resources :group_loan_run_away_receivables 
    resources :savings_entries 
    
    resources :group_loan_weekly_collection_voluntary_savings_entries
    
    resources :memorials
    resources :memorial_details 
    resources :accounts
    resources :transaction_datas
    resources :transaction_data_details 
    
    get 'search_ledger_accounts' => 'accounts#search_ledger', :as => :search_ledger_accounts 
    
    put 'confirm_memorial' => 'memorials#confirm' , :as => :confirm_memorial
    
    put 'confirm_savings_entry' => 'savings_entries#confirm' , :as => :confirm_savings_entry
    
    get 'group_loan_weekly_collection/active_group_loan_memberships' => 'group_loan_weekly_collections#active_group_loan_memberships' , :as => :get_weekly_collection_active_group_loan_memberships
    

    resources :loan_trails 
  end
end
