class Api::MembersController < Api::BaseApiController
  
  def index
    
    is_deceased_value = false 
    is_run_away_value = false 
    
    is_deceased_value = true if params[:is_deceased].present?  
    is_run_away_value = true if params[:is_run_away].present?
    
    if params[:livesearch].present? 
      livesearch = "%#{params[:livesearch]}%"
      
      if params[:is_deceased].present? or params[:is_run_away].present?
        @objects = Member.includes(:group_loan_memberships => [:group_loan]).where{
          (is_deceased.eq is_deceased_value) & 
          (is_run_away.eq is_run_away_value ) & 
          (
            (name =~  livesearch ) | 
            (id_number =~ livesearch)
          ) 
        }.page(params[:page]).per(params[:limit]).order("id DESC")

        @total = Member.where{
          (is_deceased.eq is_deceased_value) & 
          (is_run_away.eq is_run_away_value ) & 
          (
            (name =~  livesearch ) | 
            (id_number =~ livesearch )
          )
        }.count
      else
        
        @objects = Member.includes(:group_loan_memberships => [:group_loan]).where{
          # (is_deceased.eq is_deceased_value) & 
          # (is_run_away.eq is_run_away_value ) & 
          (
            (name =~  livesearch ) | 
            (id_number =~ livesearch)
          )

        }.page(params[:page]).per(params[:limit]).order("id DESC")

        @total = Member.where{
          # (is_deceased.eq is_deceased_value) & 
          # (is_run_away.eq is_run_away_value ) & 
          (
            (name =~  livesearch ) | 
            (id_number =~ livesearch )
          )
        }.count
      end
      
      
      # calendar
      
    elsif params[:is_deceased].present? 
      @objects = Member.includes(:group_loan_memberships => [:group_loan]).where(:is_deceased => true ).page(params[:page]).per(params[:limit]).order("deceased_at DESC")
      @total = Member.where(:is_deceased => true ).count
    elsif params[:is_run_away].present? 
      @objects = Member.includes(:group_loan_memberships => [:group_loan]).where(:is_run_away => true ).page(params[:page]).per(params[:limit]).order("run_away_at DESC")
      @total = Member.where(:is_run_away => true ).count
    else
      puts "In this shite"
      @objects = Member.includes(:group_loan_memberships => [:group_loan]).page(params[:page]).per(params[:limit]).order("id DESC")
      @total = Member.count 
    end
    
    
    # render :json => { :members => @objects , :total => @total , :success => true }
  end

  def create
    # @object = Member.new(params[:member])
 
    params[:member][:birthday_date] =  parse_date( params[:member][:birthday_date] ) 
    @object = Member.create_object( params[:member] )
    if @object.errors.size == 0 
      render :json => { :success => true, 
                        :members => [
                          
                            :id 							=>  	@object.id                  ,
                          	:name 			=>     @object.name   ,
                          	:id_number 		=> 	  @object.id_number  ,
                          	:address 				=> 	  @object.address      ,
                          	:is_deceased			  =>   	@object.is_deceased     ,
                          	:is_run_away		    =>   	@object.is_run_away     ,
                          	:deceased_at       =>   	format_date_friendly( @object.deceased_at )   ,
                          	:run_away_at       =>     format_date_friendly( @object.run_away_at )   
                          ] , 
                        :total => Member.active_objects.count }  
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

  def update
    @object = Member.find(params[:id])
    params[:member][:deceased_at] =  parse_date( params[:member][:deceased_at] )
    params[:member][:run_away_at] =  parse_date( params[:member][:run_away_at] )
    
    params[:member][:birthday_date] =  parse_date( params[:member][:birthday_date] ) 
    
    if params[:mark_as_deceased].present?  
      
      begin
        ActiveRecord::Base.transaction do 
          @object.mark_as_deceased(:deceased_at => params[:member][:deceased_at] )
        end
      rescue ActiveRecord::ActiveRecordError  
      else
      end

    elsif params[:unmark_as_deceased].present?

      begin
        ActiveRecord::Base.transaction do 
          @object.undo_mark_as_deceased 
        end
      rescue ActiveRecord::ActiveRecordError  
      else
      end
      
      
    elsif params[:mark_as_run_away].present?  
      puts "\n\n"
      puts "=========> GOnna mark as run away\n"*10
      
      begin
        ActiveRecord::Base.transaction do 
          @object.mark_as_run_away(:run_away_at => params[:member][:run_away_at] )
        end
      rescue ActiveRecord::ActiveRecordError  
      else
      end
      
      
    else
      @object.update_object( params[:member] )
    end
    
     
    if @object.errors.size == 0 
      render :json => { :success => true,   
                        :members => [
                          
                          :id 							=>  	@object.id                  ,
                        	:name 			=>     @object.name   ,
                        	:id_number 		=> 	  @object.id_number  ,
                        	:address 				=> 	  @object.address      ,
                        	:is_deceased			  =>   	@object.is_deceased     ,
                        	:is_run_away		    =>   	@object.is_run_away     ,
                        	:deceased_at       =>   	format_date_friendly( @object.deceased_at )   ,
                        	:run_away_at       =>     format_date_friendly( @object.run_away_at )
                        	
                        ],
                        :total => Member.active_objects.count  } 
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
  
  def show
    @object = Member.find_by_id params[:id]
    render :json => { :success => true, 
                      :members => [@object] , 
                      :total => Member.count }
  end

  def destroy
    @object = Member.find(params[:id])
    
    begin
      ActiveRecord::Base.transaction do 
        @object.delete_object 
      end
    rescue ActiveRecord::ActiveRecordError  
    else
    end
    
    

    if not @object.persisted?  
      render :json => { :success => true, :total => Member.active_objects.count }  
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
  
  
  def search
    search_params = params[:query]
    selected_id = params[:selected_id]
    if params[:selected_id].nil?  or params[:selected_id].length == 0 
      selected_id = nil
    end
    
    query = "%#{search_params}%"
    # on PostGre SQL, it is ignoring lower case or upper case 
    
    if  selected_id.nil?
      @objects = Member.where{ (name =~ query)   
                              }.
                        page(params[:page]).
                        per(params[:limit]).
                        order("id DESC")
                        
      @total = Member.where{ (name =~ query)  
                              }.count
    else
      @objects = Member.where{ (id.eq selected_id)  
                              }.
                        page(params[:page]).
                        per(params[:limit]).
                        order("id DESC")
   
      @total = Member.where{ (id.eq selected_id)   
                              }.count 
    end
    
    
    render :json => { :records => @objects , :total => @total, :success => true }
  end
end
