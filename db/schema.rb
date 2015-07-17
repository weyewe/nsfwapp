# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150515070916) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "accounts", force: true do |t|
    t.string   "name"
    t.integer  "parent_id"
    t.integer  "lft"
    t.integer  "rgt"
    t.integer  "depth"
    t.decimal  "amount",            precision: 14, scale: 2, default: 0.0
    t.boolean  "is_contra_account",                          default: false
    t.integer  "normal_balance",                             default: 1
    t.integer  "account_case",                               default: 2
    t.boolean  "is_base_account",                            default: false
    t.string   "code"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "accounts", ["parent_id"], name: "index_accounts_on_parent_id", using: :btree

  create_table "branches", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.text     "address"
    t.string   "code"
    t.integer  "branch_head_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "closings", force: true do |t|
    t.boolean  "is_first_closing",                                   default: false
    t.datetime "start_period"
    t.datetime "end_period"
    t.string   "description"
    t.decimal  "expense_adjustment_amount", precision: 14, scale: 2, default: 0.0
    t.integer  "expense_adjustment_case"
    t.decimal  "revenue_adjustment_amount", precision: 14, scale: 2, default: 0.0
    t.integer  "revenue_adjustment_case"
    t.decimal  "net_earnings_amount",       precision: 14, scale: 2, default: 0.0
    t.integer  "net_earnings_case"
    t.boolean  "is_confirmed",                                       default: false
    t.datetime "confirmed_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "deceased_clearances", force: true do |t|
    t.boolean  "is_insurance_claimable",                                default: false
    t.boolean  "is_confirmed",                                          default: false
    t.datetime "confirmed_at"
    t.boolean  "is_insurance_claim_submitted",                          default: false
    t.datetime "insurance_claim_submitted_at"
    t.boolean  "is_insurance_claim_approved",                           default: false
    t.datetime "insurance_claim_approved_at"
    t.decimal  "principal_return",             precision: 10, scale: 2, default: 0.0
    t.decimal  "donation",                     precision: 10, scale: 2, default: 0.0
    t.boolean  "is_claim_received",                                     default: false
    t.datetime "claim_received_at"
    t.boolean  "is_donation_disbursed",                                 default: false
    t.datetime "donation_disbursed_at"
    t.integer  "member_id"
    t.integer  "financial_product_id"
    t.string   "financial_product_type"
    t.text     "description"
    t.decimal  "additional_savings_account",   precision: 10, scale: 2, default: 0.0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "deceased_clearances", ["financial_product_id", "financial_product_type"], name: "deceased_clearance_source_index", using: :btree
  add_index "deceased_clearances", ["member_id"], name: "index_deceased_clearances_on_member_id", using: :btree

  create_table "delayed_jobs", force: true do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "employees", force: true do |t|
    t.integer  "branch_id"
    t.string   "name"
    t.string   "code"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "group_loan_disbursements", force: true do |t|
    t.integer  "group_loan_membership_id"
    t.integer  "group_loan_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "group_loan_disbursements", ["group_loan_id"], name: "index_group_loan_disbursements_on_group_loan_id", using: :btree
  add_index "group_loan_disbursements", ["group_loan_membership_id"], name: "index_group_loan_disbursements_on_group_loan_membership_id", using: :btree

  create_table "group_loan_memberships", force: true do |t|
    t.integer  "group_loan_id"
    t.integer  "group_loan_product_id"
    t.integer  "member_id"
    t.boolean  "is_active",                                                                    default: true
    t.integer  "deactivation_case"
    t.integer  "deactivation_week_number"
    t.decimal  "total_compulsory_savings",                            precision: 10, scale: 2, default: 0.0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "compulsory_savings_deduction_for_interest_revenue",   precision: 12, scale: 2, default: 0.0
    t.decimal  "compulsory_savings_deduction_for_bad_debt_allowance", precision: 12, scale: 2, default: 0.0
    t.decimal  "closing_bad_debt_expense",                            precision: 12, scale: 2, default: 0.0
  end

  add_index "group_loan_memberships", ["group_loan_id", "member_id"], name: "index_group_loan_memberships_on_group_loan_id_and_member_id", using: :btree
  add_index "group_loan_memberships", ["group_loan_id"], name: "index_group_loan_memberships_on_group_loan_id", using: :btree
  add_index "group_loan_memberships", ["group_loan_product_id"], name: "index_group_loan_memberships_on_group_loan_product_id", using: :btree
  add_index "group_loan_memberships", ["member_id"], name: "index_group_loan_memberships_on_member_id", using: :btree

  create_table "group_loan_premature_clearance_payments", force: true do |t|
    t.integer  "group_loan_id"
    t.integer  "group_loan_membership_id"
    t.integer  "group_loan_weekly_collection_id"
    t.decimal  "amount",                          precision: 12, scale: 2, default: 0.0
    t.boolean  "is_confirmed",                                             default: false
    t.decimal  "remaining_compulsory_savings",    precision: 12, scale: 2, default: 0.0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "group_loan_premature_clearance_payments", ["group_loan_id"], name: "gl_pcp_gl", using: :btree
  add_index "group_loan_premature_clearance_payments", ["group_loan_membership_id"], name: "gl_pcp_glm", using: :btree
  add_index "group_loan_premature_clearance_payments", ["group_loan_weekly_collection_id"], name: "gl_pcp_glwc", using: :btree

  create_table "group_loan_products", force: true do |t|
    t.string   "name"
    t.decimal  "principal",          precision: 10, scale: 2, default: 0.0
    t.decimal  "interest",           precision: 10, scale: 2, default: 0.0
    t.decimal  "compulsory_savings", precision: 10, scale: 2, default: 0.0
    t.decimal  "admin_fee",          precision: 10, scale: 2, default: 0.0
    t.decimal  "initial_savings",    precision: 10, scale: 2, default: 0.0
    t.integer  "total_weeks"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "group_loan_run_away_receivables", force: true do |t|
    t.integer  "member_id"
    t.integer  "group_loan_membership_id"
    t.integer  "group_loan_id"
    t.integer  "group_loan_weekly_collection_id"
    t.decimal  "amount_receivable",               precision: 12, scale: 2, default: 0.0
    t.boolean  "is_closed",                                                default: false
    t.integer  "payment_case"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "group_loan_run_away_receivables", ["group_loan_id"], name: "gl_rar_gl", using: :btree
  add_index "group_loan_run_away_receivables", ["group_loan_membership_id"], name: "gl_rar_glm", using: :btree
  add_index "group_loan_run_away_receivables", ["group_loan_weekly_collection_id"], name: "gl_rar_glwc", using: :btree
  add_index "group_loan_run_away_receivables", ["member_id"], name: "gl_rar_m", using: :btree

  create_table "group_loan_weekly_collection_attendances", force: true do |t|
    t.integer  "group_loan_weekly_collection_id"
    t.integer  "group_loan_membership_id"
    t.boolean  "attendance_status",               default: true
    t.boolean  "payment_status",                  default: true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "group_loan_weekly_collection_voluntary_savings_entries", force: true do |t|
    t.decimal  "amount",                          precision: 10, scale: 2, default: 0.0
    t.integer  "group_loan_membership_id"
    t.integer  "group_loan_weekly_collection_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "direction",                                                default: 1
  end

  add_index "group_loan_weekly_collection_voluntary_savings_entries", ["group_loan_membership_id"], name: "glwc_vse_glm", using: :btree
  add_index "group_loan_weekly_collection_voluntary_savings_entries", ["group_loan_weekly_collection_id"], name: "glwc_vse_glwc", using: :btree

  create_table "group_loan_weekly_collections", force: true do |t|
    t.integer  "group_loan_id"
    t.integer  "week_number"
    t.boolean  "is_collected",                                               default: false
    t.decimal  "premature_clearance_deposit_usage", precision: 10, scale: 2, default: 0.0
    t.boolean  "is_confirmed",                                               default: false
    t.datetime "collected_at"
    t.datetime "confirmed_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "tentative_collection_date"
  end

  add_index "group_loan_weekly_collections", ["group_loan_id"], name: "index_group_loan_weekly_collections_on_group_loan_id", using: :btree

  create_table "group_loan_weekly_payments", force: true do |t|
    t.integer  "group_loan_membership_id"
    t.integer  "group_loan_id"
    t.integer  "group_loan_weekly_collection_id"
    t.boolean  "is_run_away_weekly_bailout",      default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "group_loan_weekly_payments", ["group_loan_id"], name: "gl_wp_gl", using: :btree
  add_index "group_loan_weekly_payments", ["group_loan_membership_id"], name: "gl_wp_glm", using: :btree
  add_index "group_loan_weekly_payments", ["group_loan_weekly_collection_id"], name: "gl_wp_glwc", using: :btree

  create_table "group_loan_weekly_uncollectibles", force: true do |t|
    t.integer  "group_loan_weekly_collection_id"
    t.integer  "group_loan_membership_id"
    t.integer  "group_loan_id"
    t.decimal  "amount",                          precision: 12, scale: 2, default: 0.0
    t.decimal  "principal",                       precision: 12, scale: 2, default: 0.0
    t.boolean  "is_collected",                                             default: false
    t.datetime "collected_at"
    t.integer  "clearance_case",                                           default: 2
    t.boolean  "is_cleared",                                               default: false
    t.datetime "cleared_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "group_loan_weekly_uncollectibles", ["group_loan_id"], name: "glwu_gl", using: :btree
  add_index "group_loan_weekly_uncollectibles", ["group_loan_membership_id"], name: "glwu_glm", using: :btree
  add_index "group_loan_weekly_uncollectibles", ["group_loan_weekly_collection_id"], name: "glwu_glwc", using: :btree

  create_table "group_loans", force: true do |t|
    t.string   "name"
    t.integer  "number_of_meetings"
    t.integer  "number_of_collections"
    t.boolean  "is_started",                                                            default: false
    t.datetime "started_at"
    t.boolean  "is_loan_disbursement_prepared",                                         default: false
    t.boolean  "is_loan_disbursed",                                                     default: false
    t.datetime "disbursed_at"
    t.boolean  "is_closed",                                                             default: false
    t.datetime "closed_at"
    t.boolean  "is_compulsory_savings_withdrawn",                                       default: false
    t.datetime "compulsory_savings_withdrawn_at"
    t.integer  "group_leader_id"
    t.decimal  "premature_clearance_deposit",                  precision: 10, scale: 2, default: 0.0
    t.decimal  "total_compulsory_savings_pre_closure",         precision: 10, scale: 2, default: 0.0
    t.decimal  "bad_debt_allowance",                           precision: 10, scale: 2, default: 0.0
    t.decimal  "bad_debt_expense",                             precision: 10, scale: 2, default: 0.0
    t.decimal  "round_down_compulsory_savings_return_revenue", precision: 10, scale: 2, default: 0.0
    t.decimal  "interest_revenue",                             precision: 10, scale: 2, default: 0.0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "group_number"
    t.decimal  "compulsory_savings_deduction_amount",          precision: 12, scale: 2, default: 0.0
    t.decimal  "potential_loss_interest_revenue",              precision: 12, scale: 2, default: 0.0
    t.decimal  "bad_debt_allowance_capital_deduction",         precision: 12, scale: 2, default: 0.0
    t.decimal  "interest_revenue_capital_deduction",           precision: 12, scale: 2, default: 0.0
  end

  create_table "members", force: true do |t|
    t.string   "name"
    t.text     "address"
    t.string   "id_number"
    t.decimal  "total_savings_account",        precision: 12, scale: 2, default: 0.0
    t.boolean  "is_deceased",                                           default: false
    t.datetime "deceased_at"
    t.boolean  "is_run_away",                                           default: false
    t.datetime "run_away_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "id_card_number"
    t.datetime "birthday_date"
    t.boolean  "is_data_complete",                                      default: false
    t.decimal  "total_locked_savings_account", precision: 12, scale: 2, default: 0.0
    t.decimal  "total_membership_savings",     precision: 12, scale: 2, default: 0.0
    t.integer  "rt"
    t.integer  "rw"
    t.string   "village"
  end

  create_table "memorial_details", force: true do |t|
    t.datetime "transaction_datetime"
    t.integer  "memorial_id"
    t.integer  "transaction_data_id"
    t.integer  "account_id"
    t.integer  "entry_case"
    t.decimal  "amount",               precision: 14, scale: 2, default: 0.0
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "memorial_details", ["account_id"], name: "index_memorial_details_on_account_id", using: :btree
  add_index "memorial_details", ["memorial_id"], name: "index_memorial_details_on_memorial_id", using: :btree

  create_table "memorials", force: true do |t|
    t.datetime "transaction_datetime"
    t.text     "description"
    t.boolean  "is_confirmed",         default: false
    t.datetime "confirmed_at"
    t.string   "code"
    t.boolean  "is_deleted",           default: false
    t.datetime "deleted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles", force: true do |t|
    t.string   "name",        null: false
    t.string   "title",       null: false
    t.text     "description", null: false
    t.text     "the_role",    null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "savings_entries", force: true do |t|
    t.integer  "savings_source_id"
    t.string   "savings_source_type"
    t.decimal  "amount",                 precision: 10, scale: 2, default: 0.0
    t.integer  "savings_status"
    t.integer  "direction"
    t.integer  "financial_product_id"
    t.string   "financial_product_type"
    t.integer  "member_id"
    t.text     "description"
    t.boolean  "is_confirmed",                                    default: false
    t.datetime "confirmed_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_adjustment",                                   default: false
    t.string   "message"
  end

  add_index "savings_entries", ["financial_product_id", "financial_product_type"], name: "financial_product_source_index", using: :btree
  add_index "savings_entries", ["member_id"], name: "index_savings_entries_on_member_id", using: :btree
  add_index "savings_entries", ["savings_source_id", "savings_source_type"], name: "savings_entry_source_index", using: :btree

  create_table "transaction_activities", force: true do |t|
    t.integer  "transaction_source_id"
    t.string   "transaction_source_type"
    t.integer  "fund_case"
    t.decimal  "amount",                  precision: 10, scale: 2, default: 0.0
    t.integer  "direction"
    t.decimal  "savings",                 precision: 10, scale: 2, default: 0.0
    t.integer  "savings_direction"
    t.integer  "office_id"
    t.integer  "member_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "transaction_activities", ["transaction_source_id", "transaction_source_type"], name: "transaction_activity_source_index", using: :btree

  create_table "transaction_data", force: true do |t|
    t.integer  "transaction_source_id"
    t.string   "transaction_source_type"
    t.datetime "transaction_datetime"
    t.text     "description"
    t.decimal  "amount",                  precision: 14, scale: 2, default: 0.0
    t.boolean  "is_confirmed"
    t.integer  "code"
    t.boolean  "is_contra_transaction",                            default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "transaction_data_details", force: true do |t|
    t.integer  "transaction_data_id"
    t.integer  "account_id"
    t.integer  "entry_case"
    t.decimal  "amount",              precision: 14, scale: 2, default: 0.0
    t.string   "description"
    t.boolean  "is_bank_transaction",                          default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "transaction_data_details", ["account_id"], name: "index_transaction_data_details_on_account_id", using: :btree
  add_index "transaction_data_details", ["transaction_data_id"], name: "index_transaction_data_details_on_transaction_data_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "email",                  default: "",    null: false
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.integer  "role_id"
    t.string   "name"
    t.string   "username"
    t.string   "login"
    t.boolean  "is_deleted",             default: false
    t.boolean  "is_main_user",           default: false
    t.string   "authentication_token"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["role_id"], name: "index_users_on_role_id", using: :btree

  create_table "valid_comb_savings_entries", force: true do |t|
    t.integer  "member_id"
    t.integer  "month"
    t.integer  "year"
    t.integer  "savings_status"
    t.decimal  "amount",         precision: 12, scale: 2, default: 0.0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "valid_comb_savings_entries", ["member_id"], name: "index_valid_comb_savings_entries_on_member_id", using: :btree

  create_table "valid_combs", force: true do |t|
    t.integer  "closing_id"
    t.integer  "account_id"
    t.decimal  "amount",     precision: 14, scale: 2, default: 0.0
    t.integer  "entry_case"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "valid_combs", ["account_id"], name: "index_valid_combs_on_account_id", using: :btree
  add_index "valid_combs", ["closing_id"], name: "index_valid_combs_on_closing_id", using: :btree

end
