require 'spec_helper'

describe Branch do
  
  before(:each) do
    # puts "This is awesome"
  end
  
  it "should be allowed to create Branch" do
    @branch = Branch.create_object(
      :name => "Name",
      :description => "awesome description",
      :address => "awesome address",
      :code => '23423'
    )
    

    @branch.should be_valid 
  end
  
  it "should NOT be allowed to create Branch without name " do
    @branch = Branch.create_object(
      :name => "",
      :description => "awesome description",
      :address => "awesome address",
      :code => "32"
    )
    
    @branch.errors.size.should_not == 0 

    @branch = Branch.create_object(
      :name => nil,
      :description => "awesome description",
      :address => "awesome address",
      :code => "3afw3r2"
    )
    @branch.errors.size.should_not == 0 
  end
 
  
  context "created Branch" do
    before(:each) do
      @name = "Name"
      @branch = Branch.create_object(
        :name => @name,
        :description => "awesome description",
        :address => "awesome address",
        :code => "234"
      )
    end
    
    it "should not be allowed to confirm Branch" do
      @branch.errors.size.should ==  0
      @branch.should be_valid
    end

    it "should not be allowed to create duplicate branch name" do
      @name = "Name"
      @branch = Branch.create_object(
        :name => @name,
        :description => "awesome description",
        :address => "awesome address",
        :code => "8238"
      )
      @branch.errors.size.should_not == 0 
      @branch.should_not be_valid 
    end
  end
  
  
end
