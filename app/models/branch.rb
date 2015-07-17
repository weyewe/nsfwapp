class Branch < ActiveRecord::Base
  # attr_accessible :title, :body
  # belongs_to :office 

  has_many :employees
  
        
  validates_presence_of :name, :code
  validates_uniqueness_of :name , :code


  
  def self.active_objects
    self
  end  
  
  def self.create_object(   params) 
    new_object                 = self.new 
    new_object.name            = params[:name]
    new_object.description     = params[:description]
    new_object.address     = params[:address]
    new_object.code  = params[:code]

    new_object.save 
    return new_object
  end
  
  def update_object( params ) 
    
    self.name            = params[:name]
    self.description     = params[:description]
    self.address     = params[:address]
    self.code = params[:code]
    
    self.save 

    return self
  end
  
  def delete_object
  end

  def assign_branch_head(employee_id)
  	if not self.employees.map{|x| x.id }.include?(employee_id)
  		self.errors.add(:branch_head_id, "Karyawan tidak terdaftar")
  		return self 
  	end

  	self.branch_head_id = employee_id 
  	self.save
  	
  	return self  
  end
  
end
