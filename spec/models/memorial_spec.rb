require 'spec_helper'

describe Memorial do
  
  before(:each) do
    puts "This is awesome"
  end
  
  it "should be allowed to create memorial" do
    @memorial = Memorial.create_object(
      :transaction_datetime => DateTime.now ,
      :description => "awesome description"
    )
    
    @memorial.should be_valid 
  end
  
  it "should NOT be allowed to create memorial without date " do
    @memorial = Memorial.create_object(
      :transaction_datetime => nil,
      :description => "awesome description"
    )
    
    @memorial.errors.size.should_not == 0 
  end
  
  it "should NOT be allowed to create memorial without description " do
    @memorial = Memorial.create_object(
      :transaction_datetime => DateTime.now,
      :description => ""
    )
    
    @memorial.errors.size.should_not == 0 
  end
  
  context "created memorial" do
    before(:each) do
      @memorial = Memorial.create_object(
        :transaction_datetime => DateTime.now ,
        :description => "awesome description"
      )
    end
    
    it "should not be allowed to confirm memorial" do
      @memorial.confirm(:confirmed_at => DateTime.now )
      @memorial.is_confirmed.should be_falsy
    end
  end
  
  
end
