GL_STATUS = {
  :credit => 1, 
  :debit => 2 
}


ACCOUNT_GROUP = {
  :asset => 1,
  :expense => 2, 
  :liability => 3, 
  :revenue => 4, 
  :equity => 5 
  
}



NORMAL_BALANCE = {
  :debit => 1 , 
  :credit => 2 
}

ACCOUNT_CASE = {
  :group => 1,  # group => can't create transaction on group_account
  # group account can have sub_groups and ledger_account 
  :ledger => 2  # ledger_account is where the journal is associated to
} 
 

 
=begin
counter = 0 
ACCOUNT_CODE.each do |key,value|
  counter++
end

convert ACCOUNT_CODE into 2 dimensional array 
[
  [symbol, code ]
]

converted = []
ACCOUNT_CODE.each do |key,value|
  converted << [ key, value[:code] ] 
end
sorted = converted.sort_by {|x| x[1]}


sorted.each do |x|
  account = ACCOUNT_CODE[x[0]]
  
end
=end
 
# level 0
ACCOUNT_CODE = {
  :activa => {
    :code => "1-000",
    :name => "AKTIVA",
    :normal_balance => 1,
    :status => 1,
    :parent_code => nil
  },
    :current_asset => {
      :code => "1-100",
      :name => "AKTIVA LANCAR",
      :normal_balance => 1,
      :status => 1,
      :parent_code => "1-000"
    },
      :cash_and_others => {
        :code => "1-110",
        :name => "Kas dan setara kas",
        :normal_balance => 1,
        :status => 1,
        :parent_code =>  "1-100"
      },
        :main_cash_leaf => {
          :code => "1-111",
          :name => "Kas Besar",
          :normal_balance => 1,
          :status => 2, # ledger# 
          :parent_code =>  "1-110"
        },
    :account_receivable =>     {
          :code => "1-140",
          :name => "Piutang",
          :normal_balance => 1,
          :status => 1,
          :parent_code =>  "1-100"
        },
      :pinjaman_sejahtera_ar_leaf =>   {
              :code => "1-141",
              :name => "Piutang Pinjaman Sejahtera",
              :normal_balance => 1,
              :status => 2, # ledger
              :parent_code =>  "1-140"
            },
    :bad_debt_allocation =>         {
                    :code => "1-150",
                    :name => "Penyisihan Piutang Tak Tertagih",
                    :normal_balance => 1,
                    :status => 1,
                    :parent_code =>  "1-100"
                  },
      :pinjaman_sejahtera_bda_leaf =>             {
                                  :code => "1-151",
                                  :name => "Penyisihan Piutang Tak Tertagih Pinjaman Sejahtera",
                                  :normal_balance => 1,
                                  :status => 2, # ledger
                                  :parent_code =>  "1-150"
                                },
      
      
  :liability =>  {
    :code => "2-000",
    :name => "KEWAJIBAN",
    :normal_balance => 2,
    :status => 1,
    :parent_code =>  nil
  },
    :current_liability =>{
      :code =>  "2-100",
      :name => "KEWAJIBAN LANCAR",
      :normal_balance => 2,
      :status => 1,
      :parent_code =>  "2-000"
    },
      :savings =>{
        :code =>   "2-110",
        :name => "Tabungan",
        :normal_balance => 2,
        :status => 1,
        :parent_code =>  "2-100"
      },
        :compulsory_savings_leaf =>{
          :code =>    "2-111",
          :name => "Tabungan Wajib",
          :normal_balance => 2,
          :status => 2, # ledger
          :parent_code =>  "2-110"
        },
        :voluntary_savings_leaf => {
          :code =>    "2-112",
          :name => "Tabungan Pribadi",
          :normal_balance => 2,
          :status => 2, # ledger
          :parent_code =>  "2-110"
        },
        :locked_savings_leaf => {
          :code =>    "2-113",
          :name => "Tabungan Masa Depan",
          :normal_balance => 2,
          :status => 2 ,# ledger
          :parent_code =>  "2-110"
        },
        :membership_savings_leaf => {
          :code =>    "2-114",
          :name => "Tabungan Keanggotaan",
          :normal_balance => 2,
          :status => 2 ,# ledger
          :parent_code =>  "2-110"
        },
      :other_current_liability =>   {
          :code =>    "2-190",
          :name => "Utang Lancar Lainnya",
          :normal_balance => 2,
          :status => 1 ,# group
          :parent_code =>  "2-113"
        },
        :utang_santunan_leaf => {
            :code =>    "2-191",
            :name => "Utang santunan",
            :normal_balance => 2,
            :status => 2, # ledger
            :parent_code =>  "2-190"
          },
        :uang_titipan_leaf =>   {
              :code =>    "2-192",
              :name => "Uang titipan",
              :normal_balance => 2,
              :status => 2, # ledger 
              :parent_code =>  "2-190"
            },
        :pending_group_loan_member_cash_return_leaf =>   {
              :code =>    "2-193",
              :name => "Pending Pengembalian",
              :normal_balance => 2,
              :status => 2, # ledger 
              :parent_code =>  "2-190"
            },
            
        
  :equity => {
        :code =>    "3-000",
        :name => "EKUITAS",
        :normal_balance => 2,
        :status => 1, # group 
        :parent_code =>  nil 
      },
      :equity_1 =>      {
                  :code =>  "3-100",
                  :name => "Ekuitas",
                  :normal_balance => 2,
                  :status => 1,  
                  :parent_code =>  "3-000" 
                } ,
         :equity_2 =>        {
                      :code =>    "3-110",
                      :name => "Ekuitas",
                      :normal_balance => 2,
                      :status => 1,
                      :parent_code =>  "3-100" 
                    } ,
            :net_earning_leaf =>        {
                          :code =>    "3-111",
                          :name => "Net Earning",
                          :normal_balance => 2,
                          :status => 2,
                          :parent_code =>  "3-110" 
                        } ,
  
  
  :operating_revenue =>     {
            :code =>    "4-000",
            :name => "PENDAPATAN USAHA",
            :normal_balance => 2,
            :status => 1, # group 
            :parent_code =>  nil 
          },
    :loan_revenue =>      {
                :code =>  "4-100",
                :name => "Pendapatan pinjaman",
                :normal_balance => 2,
                :status => 1,  
                :parent_code =>  "4-000" 
              } ,
      :loan_administration_revenue =>        {
                    :code =>    "4-110",
                    :name => "Pendapatan administrasi pinjaman",
                    :normal_balance => 2,
                    :status => 1,
                    :parent_code =>  "4-100" 
                  } ,
        :pinjaman_sejahtera_administration_revenue_leaf => {
              :code =>    "4-111",
              :name => "Pendapatan administrasi pinjaman Sejahtera",
              :normal_balance => 2,
              :status => 2,
              :parent_code =>  "4-110" 
            },
      :interest_revenue =>      {
                  :code =>   "4-120",
                  :name => "Pendapatan bagi hasil pinjaman",
                  :normal_balance => 2,
                  :status => 1, # group 
                  :parent_code =>   "4-100" 
                } ,
        :pinjaman_sejahtera_interest_revenue_leaf =>{
              :code =>    "4-121",
              :name => "Pendapatan bagi hasil pinjaman Sejahtera",
              :normal_balance => 2,
              :status => 2, 
              :parent_code =>  "4-120" 
            },
        
  :financial_expense =>          {
                  :code =>    "5-000",
                  :name => "BEBAN KEUANGAN",
                  :normal_balance => 1,
                  :status => 1, # group 
                  :parent_code =>  nil 
                } ,
  
  :operating_expense =>  {
          :code =>   "6-000" ,
          :name => "BEBAN USAHA",
          :normal_balance => 1,
          :status => 1, # group 
          :parent_code =>  nil 
        } ,
    :account_receivable_allowance_expense =>  {
            :code =>   "6-200",
            :name => "Beban Penghapusan Piutang",
            :normal_balance => 1,
            :status => 1, # group 
            :parent_code =>  "6-000"  
          } ,
      :account_receivable_allowance_expense_1 =>    {
                :code =>   "6-210",
                :name => "Beban Penghapusan Piutang",
                :normal_balance => 1,
                :status => 1, # group 
                :parent_code =>   "6-200" 
              } ,
        :pinjaman_sejahtera_arae_leaf =>      {
                    :code =>    "6-211",
                    :name => "Beban Penghapusan Piutang Pinjaman Sejahtera",
                    :normal_balance => 1,
                    :status => 2,
                    :parent_code =>  "6-210" 
                  } ,
        
  :other_revenue => {
        :code =>    "7-000",
        :name => "PENDAPATAN LAIN-LAIN",
        :normal_balance => 2,
        :status => 1, # group 
        :parent_code =>  nil 
      } ,
    :other_revenue_1 =>  {
            :code =>    "7-100",
            :name => "Pendapatan lain-lain",
            :normal_balance => 2,
            :status => 1, # group 
            :parent_code =>   "7-000" 
          } ,
      :other_revenue_2 =>    {
                :code =>   "7-110",
                :name => "Pendapatan lain-lain",
                :normal_balance => 2,
                :status => 1, # group 
                :parent_code =>   "7-100" 
              } ,
        :other_revenue_leaf =>{
              :code =>   "7-118",
              :name => "Pembulatan nilai",
              :normal_balance => 2,
              :status => 2,
              :parent_code =>   "7-110" 
            } ,
        
  :other_expense =>          {
                  :code =>    "8-000",
                  :name => "BEBAN LAIN-LAIN",
                  :normal_balance => 1,
                  :status => 1, # group 
                  :parent_code =>  nil 
                } ,
  
  :coop_expense => {
        :code =>    "9-000",
        :name => "BEBAN PERKOPERASIAN",
        :normal_balance => 1,
        :status => 1, # group 
        :parent_code =>  nil 
      },
}

# public class AccountCode
# {
#     public static string Asset = "1";
#     public static string CashBank = "11";
#     public static string AccountReceivable = "12";
#     public static string GBCHReceivable = "13";
#     public static string Inventory = "14";
#     public static string Expense = "2";
#     public static string COGS = "21";
#     public static string CashBankAdjustmentExpense = "22";
#     public static string Discount = "23";
#     public static string SalesAllowance = "24";
#     public static string StockAdjustmentExpense = "25";
#     public static string Liability = "3";
#     public static string AccountPayable = "31";
#     public static string GBCHPayable = "32";
#     public static string GoodsPendingClearance = "33";
#     public static string Equity = "4";
#     public static string OwnersEquity = "41";
#     public static string EquityAdjustment = "411";
#     public static string Revenue = "5";
# }
# 
# public class AccountLegacyCode
# {
#     public static string Asset = "A1";
#     public static string CashBank = "A11";
#     public static string AccountReceivable = "A12";
#     public static string GBCHReceivable = "A13";
#     public static string Inventory = "A14";
#     public static string Expense = "X1";
#     public static string COGS = "X11";
#     public static string CashBankAdjustmentExpense = "X12";
#     public static string Discount = "X13";
#     public static string SalesAllowance = "X14";
#     public static string StockAdjustmentExpense = "X15";
#     public static string Liability = "L1";
#     public static string AccountPayable = "L11";
#     public static string GBCHPayable = "L12";
#     public static string GoodsPendingClearance = "L13";
#     public static string Equity = "E1";
#     public static string OwnersEquity = "E11";
#     public static string EquityAdjustment = "E111";
#     public static string Revenue = "R1";
# 
#     public static string Unknown = "U1";
# }

=begin
Automated journaling

Debit side 
1-000 Aktiva
  1-100 Aktiva lancar 
    1-110 Kas dan setara kas
      1-111 Kas besar
      1-114 BRI    # menerima premi asuransi 
    1-140 Piutang 
      1-141 Piutang Pinjaman Sejahtera
    1-150 Penyisihan Piutang Tak Tertagih
      1-151 Penyisihan Piutang Tak Tertagih Pinjaman Sejahtera
      
      
2-000 Kewajiban
  2-100 Kewajiban Lancar
    2-110 Tabungan
      2-111 Tabungan Wajib
      2-112 Tabungan Pribadi
      2-113 Tabungan Masa Depan
    2-190 Utang Lancar Lainnya
      2-191 Utang Santunan
      2-192 Uang Titipan 
      
6-000 Beban Usaha
  6-200 Beban Penghapusan Piutang
    6-210 Beban Penghapusan Piutang
      6-211 Beban Penghapusan Piutang Pinjaman Sejahtera

      
    
4-000 Pendapatan Usaha
    4-100 Pendapatan Pinjaman
      4-110 Pendapatan Administrasi Pinjaman
        4-111 Pendapatan administrasi pinjaman sejahtera
        
      4-120 Pendapatan bagi hasil pinjaman
        4-121 Pendapatan bagi hasil pinjaman sejahtera
        
7-000 Pendapatan Lain-lain
  7-100 Pendapatan lain-lain
    7-110 Pendapatan lain-lain
      7-118 Pembulatan Nilai
      
        
      
1. 1-141 OK 
2. 1-111 OK 
3. 2-111 OK
4. 2-112 OK 
5. 2-113 OK 
6. 1-151 OK 
7. 6-211 OK 
8. 1-141 OK 
9. 1-114 OK 
10. 2-191 OK 
11. 2-192 OK 


Credit side
1. 1-111 OK 
2. 4-111 OK 
3. 1-141 OK 
4. 4-121 OK 
5. 2-111 OK 
6. 2-112 OK 
7. 2-113 OK 
8. 1-151 OK 
9. 2-191 OK 
10. 2-192 OK 
11. 7-118 OK 
12. 6-211 OK 



TRANSACTION LIST

1. Loan Disbursement
2. Weekly Payment
3. Savings Distribution  (compulsory savings part)
4. Voluntary Savings Withdrawal
5. Locked Savings Withdrawal
6. Voluntary Savings Addition
7. Locked Savings Addition
8. Member Run Away
  8.a. Jurnal pada saat  run away disetujui kantor pusat
  8.b. Jurnal penerimaan pembayaran cicilan pinjaman
  8.c. Jurnal di akhir periode: 
    8.c.1 Jurnal jika tabungan wajib cukup untuk principal + bunga
    8.c.1 Jurnal jika tabungan wajib hanya cukup untuk principal
    8.c.3 Jurnal jika tabungan wajib tidak cukup untuk principal
9.Deceased Member
    9.a. Jurnal di pembayaran cicilan mingguan 
    9.b. Jurnal ketika premi diterima 
10. Premature Clearance: jika tidak ada member run away sebelumnya
  10.a. jurnal pada saat permintaan pelunasan premature clearance
        Penerimaan pembayaran per normal di minggu tersebut 
        Permintaan pelunasan di minggu N, untuk minggu N+1 sampai akhir 
  10.b. jurnal pada saat penerimaan pembayaran pelunasan premature clearance
        Pembayaran sisa dari minggu N+1 sampai minggu terakhir   [principal + interest + compulsory savings]
  10.c. jurnal di minggu berikutnya , tanpa orang tersebut 
        
11. Premature Clearance: jika ada member run away sebelumnya (ada outstanding default), paid @the end of term
  11.a. Setoran dilakukan per normal, tidak termasuk tanggung renteng karena dilakukan terakhir 
  11.b. Melunasi sisa pokok pinjaman + bagiannya untuk principal + bunga dari nasabah yg kabur [ tidak perlu membayar interest + compulsory savings]

12. Premature Clearance: member run away paid weekly
13. 


How to create posting?

GeneralLedger.create_posting(
  Account.find_by_code( ACCOUNT_CODE[:main_cash], source_document, GL_STATUS[:credit], amount )
  Account.find_by_code( ACCOUNT_CODE[:main_cash], source_document, GL_STATUS[:debit], amount )
)
=end

TRANSACTION_DATA_CODE = {
  :loan_disbursement => 10,
  :group_loan_weekly_collection => 20, 
  :group_loan_weekly_collection_voluntary_savings => 30, 
  :group_loan_premature_clearance_remaining_weeks_payment => 40 ,
  :group_loan_premature_clearance_deposit => 50 ,
  :group_loan_uncollectible_declaration => 60, 
  :group_loan_uncollectible_in_cycle_clearance => 70 ,
  :group_loan_uncollectible_end_of_cycle_clearance => 80 ,  
  :group_loan_in_cycle_uncollectible_clearance => 100, 
  :group_loan_run_away_declaration => 110 , 
  :group_loan_run_away_in_cycle_clearance => 120, 
  :group_loan_run_away_end_of_cycle_clearance => 130, 
  :group_loan_deceased_declaration => 140, 
  :group_loan_weekly_collection_round_up => 150,
  :group_loan_close_member_compulsory_savings_deduction_for_bad_debt_allowance => 160,
  :port_compulsory_savings_and_premature_clearance_deposit => 180,
  :group_loan_close_compulsory_savings_deposit_deduction_for_bad_debt_allowance => 181,
  :group_loan_close_withdrawal_return_rounding_down_revenue => 182,
  :group_loan_close_withdrawal_return  => 183,
  
  :savings_account => 200,
  :membership_savings_account => 201,
  :locked_savings_account => 203,
  :memorial_general => 300
  
  
}



