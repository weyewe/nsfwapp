class Employee < ActiveRecord::Base
  # attr_accessible :title, :body
  # belongs_to :office 

  belongs_to :branch
  
        
  validates_presence_of :name
  validates_uniqueness_of :name 
  validates_presence_of :code
  validates_uniqueness_of :code

  
  validate :branch_id_must_be_valid 

  def self.active_objects
    self
  end

  def branch_id_must_be_valid
    if branch_id.nil?
      self.errors.add(:branch_id, "Branch id harus valid")
      return self 
    end

    branch = Branch.find_by_id( branch_id )

    if  branch.nil?
      self.errors.add(:branch_id, "Branch id harus valid")
      return self 
    end


  end
  
  def self.create_object(   params) 
    new_object                 = self.new 


   
    new_object.branch_id       = params[:branch_id]
    new_object.name            = params[:name]
    new_object.description     = params[:description]
    new_object.code             = params[:code]
    # new_object.title     = params[:title]

    new_object.save 

    return new_object
  end
  
  def update_object( params ) 
    
    self.branch_id       = params[:branch_id]
    self.name            = params[:name]
    self.description     = params[:description]
    self.code = params[:code]
    # self.title     = params[:title]
    
    self.save 

    return self
  end
  
  def delete_object
  end

  
end
