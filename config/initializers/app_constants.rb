ROLE_NAME = {
  :admin => "admin",
  :manager => "manager",
  :data_entry => "dataentry"
}

 

# => TIMEZONE ( for 1 store deployment. For multitenant => different story) 
UTC_OFFSET = 7 
LOCAL_TIME_ZONE = "Jakarta" 

EXT_41_JS = 'https://s3.amazonaws.com/weyewe-extjs/41/ext-all.js'

EXTENSIBLE = 'https://s3.amazonaws.com/weyewe-extjs/extensible-all.js'

VIEW_VALUE = {
  :week => 0, 
  :month => 1, 
  :year => 2 
}
 

IMAGE_ASSET_URL = {
  
  # MSG BOX
  :alert => 'http://s3.amazonaws.com/salmod/app_asset/msg-box/alert.png',
  :background => 'http://s3.amazonaws.com/salmod/app_asset/msg-box/background.png',
  :confirm => 'http://s3.amazonaws.com/salmod/app_asset/msg-box/confirm.png',
  :error => 'http://s3.amazonaws.com/salmod/app_asset/msg-box/error.png',
  :info => 'http://s3.amazonaws.com/salmod/app_asset/msg-box/info.png',
  :question => 'http://s3.amazonaws.com/salmod/app_asset/msg-box/question.png',
  :success => 'http://s3.amazonaws.com/salmod/app_asset/msg-box/success.png',
  
  
  # FONT 
  :font_awesome_eot => 'http://s3.amazonaws.com/salmod/app_asset/font/fontawesome-webfont.eot',
  :font_awesome_svg => 'http://s3.amazonaws.com/salmod/app_asset/font/fontawesome-webfont.svg',
  :font_awesome_svgz =>'http://s3.amazonaws.com/salmod/app_asset/font/fontawesome-webfont.svgz',
  :font_awesome_ttf => 'http://s3.amazonaws.com/salmod/app_asset/font/fontawesome-webfont.ttf',
  :font_awesome_woff => 'http://s3.amazonaws.com/salmod/app_asset/font/fontawesome-webfont.woff',  
  
  
  # BOOTSTRAP SPECIFIC 
  :glyphicons_halflings_white => 'http://s3.amazonaws.com/salmod/app_asset/bootstrap/glyphicons-halflings-white.png',
  :glyphicons_halflings_black => 'http://s3.amazonaws.com/salmod/app_asset/bootstrap/glyphicons-halflings.png',
  
  # jquery UI-lightness 
  :ui_bg_diagonal_thick_18 => 'http://s3.amazonaws.com/salmod/app_asset/jquery-ui/ui-bg_diagonals-thick_18_b81900_40x40.png',
  :ui_bg_diagonal_thick_20 => 'http://s3.amazonaws.com/salmod/app_asset/jquery-ui/ui-bg_diagonals-thick_20_666666_40x40.png',
  :ui_bg_flat_10 => 'http://s3.amazonaws.com/salmod/app_asset/jquery-ui/ui-bg_flat_10_000000_40x100.png' , 
  :ui_bg_glass_100_f6f6f6 => 'http://s3.amazonaws.com/salmod/app_asset/jquery-ui/ui-bg_glass_100_f6f6f6_1x400.png',
  :ui_bg_glass_100 => 'http://s3.amazonaws.com/salmod/app_asset/jquery-ui/ui-bg_glass_100_fdf5ce_1x400.png',
  :ui_bg_glass_65 => 'http://s3.amazonaws.com/salmod/app_asset/jquery-ui/ui-bg_glass_65_ffffff_1x400.png',
  :ui_bf_gloss_wave => 'http://s3.amazonaws.com/salmod/app_asset/jquery-ui/ui-bg_gloss-wave_35_f6a828_500x100.png',
  :ui_bg_highlight_soft_100 => 'http://s3.amazonaws.com/salmod/app_asset/jquery-ui/ui-bg_gloss-wave_35_f6a828_500x100.png',
  :ui_bg_highlight_soft_75 => 'http://s3.amazonaws.com/salmod/app_asset/jquery-ui/ui-bg_highlight-soft_75_ffe45c_1x100.png',
  :ui_icons_222222 => 'http://s3.amazonaws.com/salmod/app_asset/jquery-ui/ui-icons_222222_256x240.png',
  :ui_icons_228ef1 => 'http://s3.amazonaws.com/salmod/app_asset/jquery-ui/ui-icons_228ef1_256x240.png',
  :ui_icons_ef8c08 => 'http://s3.amazonaws.com/salmod/app_asset/jquery-ui/ui-icons_ef8c08_256x240.png',
  :ui_icons_ffd27a => 'http://s3.amazonaws.com/salmod/app_asset/jquery-ui/ui-icons_ffd27a_256x240.png',
  :ui_icons_ffffff => 'http://s3.amazonaws.com/salmod/app_asset/jquery-ui/ui-icons_ffffff_256x240.png',
  :ui_bg_highlight_soft_100_eeeeee => 'http://s3.amazonaws.com/salmod/app_asset/jquery-ui/ui-bg_highlight-soft_100_eeeeee_1x100.png',
  
  
  # APP_APPLICATION.css 
  :jquery_handle => 'http://s3.amazonaws.com/salmod/app_asset/app_application/handle.png',
  :jquery_handle_vertical => 'http://s3.amazonaws.com/salmod/app_asset/app_application/handle-vertical.png',
  :login_bg => 'http://s3.amazonaws.com/salmod/app_asset/app_application/login-bg.png',
  :user_signin => 'http://s3.amazonaws.com/salmod/app_asset/app_application/user.png',
  :password => 'http://s3.amazonaws.com/salmod/app_asset/app_application/password.png',
  :password_error => 'http://s3.amazonaws.com/salmod/app_asset/app_application/password_error.png',
  :check_signin => 'http://s3.amazonaws.com/salmod/app_asset/app_application/check.png',
  :twitter => 'http://s3.amazonaws.com/salmod/app_asset/app_application/twitter_btn.png',
  :fb_button => 'http://s3.amazonaws.com/salmod/app_asset/app_application/fb_btn.png',
  :validation_error => 'http://s3.amazonaws.com/salmod/app_asset/app_application/validation-error.png',
  :validation_success => 'http://s3.amazonaws.com/salmod/app_asset/app_application/validation-success.png',
  :zoom => 'http://s3.amazonaws.com/salmod/app_asset/app_application/zoom.png',
  :logo => 'http://s3.amazonaws.com/salmod/app_asset/app_application/logo.png' 
}


=begin
  Group Loan Specific
=end

GROUP_LOAN_DEACTIVATION_CASE = {
  :financial_education_absent => 1, 
  :loan_disbursement_absent => 2 ,
  :finished_group_loan => 3 ,
  
  
  :deceased => 10,
  :run_away => 11,
  :premature_clearance => 12 
}

FUND_TRANSFER_DIRECTION = {
  :incoming => 1,
  :outgoing => 2 
}


FUND_TRANSFER_CASE= {
  :cash => 1,  
  :savings => 2 
}


SAVINGS_STATUS = {
  :savings_account => 0 ,  # the base savings account. every member has it. 
  :membership => 1, 
  :locked => 2, 
  
  :group_loan_compulsory_savings => 10,
  :group_loan_voluntary_savings => 11
  
}

GROUP_LOAN_RUN_AWAY_RECEIVABLE_CASE = {
  :weekly => 1, 
  :end_of_cycle => 2 
}

GROUP_LOAN_RUN_AWAY_RECEIVABLE_PAYMENT_CASE = {
  :weekly => 1, 
  :end_of_cycle => 2 ,
  :extra_payment => 3 
}


DEFAULT_PAYMENT_ROUND_UP_VALUE = BigDecimal("500")

PORT_GROUP_LOAN_COMPULSORY_SAVINGS_CASE = {
  :group_loan_closing => 1 , 
  :deceased_member => 2, 
  :premature_clearance => 3, 
  # :run_away_member => 4   # nope, run away member , the compulsory savings will be counted as "Other Revenue"
}


UNCOLLECTIBLE_CLEARANCE_CASE = {
  :end_of_cycle => 1, 
  :in_cycle => 2 
}

# 
# 
# Example of “nomor rekening”: • 0001.0005.1.1 -> Rekening Pinjaman SEJAHERA Ibu Atun
# 
# • 0001.0005.1.2-> Rekening Pinjaman PRIBADI Ibu Atun
# 
# • 0001.0005.2.1-> Rekening Tabungan ANGGOTA Ibu Atun
# 
# • 0001.0005.2.2-> Rekening Tabungan WAJIB Ibu Atun
# 
# • 0001.0005.2.3-> Rekening Tabungan LATIHAN Ibu Atun
# 
# • 0001.0005.2.4-> Rekening Tabungan MASA DEPAN Ibu Atun

# 
# 
# • Following is the allocation of code for each product (can be added in the 
# 
# future using other available digit): 
# • 1.1 -> Pinjaman SEJAHTERA
# 
# • 1.2 -> Pinjaman PRIBADI 
# • 2.1 -> Tabungan ANGGOTA (to become KKI member) 
# • 2.2 -> Tabungan WAJIB (weekly compulsory savings) 
# • 2.3 -> Tabungan LATIHAN (% of compulsory savings hold for xx period 
# before disbursed altogether) 
# • 2.4 -> Tabungan MASA DEPAN (stored and withdraw anytime)


# 1 is for loan, 
# 2 is for savings
SAVINGS_PRODUCT_CODE = {
  :membership => "2.1", # initial_savings payable
  # total_membership_savings
  :compulsory => "2.2", # the one attached to group loan 
  :training => "2.3",  # % of compulsory savings hold for xx loan period 
   # total_locked_savings_account
  :future => "2.4"  # voluntary savings?
  # total_savings_account
  
}

CASH_BANK_STATUS = {
  :bank => 1,
  :cashier => 2,
  :other_cash => 3 
}


# print out report
TRANSACTION_NUMBER_COLUMN = 0
TRANSACTION_DESCRIPTION = 1 
TRANSACTION_DATETIME = 2 
DEBIT_ACCOUNT_NAME = 3
DEBIT_AMOUNT = 4
CREDIT_ACCOUNT_NAME = 5
CREDIT_AMOUNT = 6

LOCKED_SAVINGS_NUMBER_COLUMN = 0
LOCKED_SAVINGS_MEMBER_ID = 1 
LOCKED_SAVINGS_MEMBER_NAME = 2 
LOCKED_SAVINGS_TRANSACTION_DATE = 3
LOCKED_SAVINGS_TRANSACTION_TYPE = 4
LOCKED_SAVINGS_TRANSACTION_AMOUNT = 5
LOCKED_SAVINGS_LAST_GROUP_NO = 6
LOCKED_SAVINGS_LAST_GROUP_NAME = 7

PAYMENT_DAY = {
  :monday => 1, 
  :tuesday => 2, 
  :wednesday => 3, 
  :thursday => 4 , 
  :friday => 5,
  :saturday => 6,
  :sunday => 7
}

TITLE_SELECTION = {
  :field_officer => 1, 
  :branch_head => 2 
}



LIMIT_REDDIT  = 50