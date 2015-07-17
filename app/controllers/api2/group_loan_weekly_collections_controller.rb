class Api2::GroupLoanWeeklyCollectionsController < Api2::BaseReportApiController


  def first_uncollected_weekly_collection 
    @parent = GroupLoan.find_by_id params[:group_loan_id]
    @object = @parent.first_uncollected_weekly_collection 

    @objects = @parent.active_group_loan_memberships.joins(:member, :group_loan_product)
    @total = @objects.count 
  end



  def update
    @object = GroupLoanWeeklyCollection.find(params[:id])
    
    
    params[:group_loan_weekly_collection][:collected_at] =  parse_date( params[:group_loan_weekly_collection][:collected_at] ) 
    params[:group_loan_weekly_collection][:confirmed_at] =  parse_date( params[:group_loan_weekly_collection][:confirmed_at] ) 

    if params[:collect].present?  
      if not current_user.has_role?( :group_loan_weekly_collections, :collect)
        render :json => {:success => false, :access_denied => "Tidak punya authorisasi"}
        return
      end
      
      begin
        ActiveRecord::Base.transaction do 
          @object.collect(:collected_at => params[:group_loan_weekly_collection][:collected_at] )
        end
      rescue ActiveRecord::ActiveRecordError  
      else
      end
      
      
      
    elsif params[:uncollect].present?
      
      if not current_user.has_role?( :group_loan_weekly_collections, :uncollect)
        render :json => {:success => false, :access_denied => "Tidak punya authorisasi"}
        return
      end
      
      begin
        ActiveRecord::Base.transaction do 
          @object.uncollect 
        end
      rescue ActiveRecord::ActiveRecordError  
      else
      end
      
      
      
    elsif params[:confirm].present?
      
      if not current_user.has_role?( :group_loan_weekly_collections, :confirm)
        render :json => {:success => false, :access_denied => "Tidak punya authorisasi"}
        return
      end
      
      begin
        ActiveRecord::Base.transaction do 
          @object.confirm( :confirmed_at => params[:group_loan_weekly_collection][:confirmed_at] )
        end
      rescue ActiveRecord::ActiveRecordError  
      else
      end
      
      
      
    elsif params[:unconfirm].present?
      
      if not current_user.has_role?( :group_loan_weekly_collections, :unconfirm)
        render :json => {:success => false, :access_denied => "Tidak punya authorisasi"}
        return
      end
      
      begin
        ActiveRecord::Base.transaction do 
          @object.unconfirm 
        end
      rescue ActiveRecord::ActiveRecordError  
      else
      end
      
      
    else
      @object.update_object(params[:group_loan_weekly_collection])
    end
    
    # @object.update_object( params[:group_loan] )
    if @object.errors.size == 0 
      render :json => { :success => true,   
                        :group_loan_weekly_collections => [
                            :id               =>    @object.id                  ,
                            :group_loan_id      =>     @object.group_loan_id   ,
                            :group_loan_name    =>    @object.group_loan.name  ,
                            :week_number        =>    @object.week_number      ,
                            :is_collected       =>    @object.is_collected     ,
                            :is_confirmed       =>    @object.is_confirmed     ,
                            :collected_at       =>    format_date_friendly( @object.collected_at )   ,
                            :confirmed_at       =>     format_date_friendly( @object.confirmed_at )  ,
                            :group_loan_weekly_uncollectible_count        => @object.group_loan_weekly_uncollectible_count,
                            :group_loan_deceased_clearance_count          => @object.group_loan_deceased_clearance_count  ,
                            :group_loan_run_away_receivable_count         => @object.group_loan_run_away_receivable_count ,
                            :group_loan_premature_clearance_payment_count => @object.group_loan_premature_clearance_payment_count,
                            :amount_receivable => @object.amount_receivable 
                             
                          ],
                        :total => GroupLoanWeeklyCollection.count  } 
    else
      msg = {
        :success => false, 
        :message => {
          :errors => extjs_error_format( @object.errors )  
        }
      }
      
      render :json => msg
    end
  end
end


