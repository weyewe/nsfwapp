class SubReddit < ActiveRecord::Base
	has_many :images
	validates_uniqueness_of :name  
	validates_presence_of :name

	def self.create_object( params ) 
		new_object  = self.new
		new_object.name  = params[:name]
		new_object.save

		return new_object
	end

	def update_object( params ) 
		self.name = params[:name]
		self.save

		return self 
	end


	def delete_object( params ) 
		if  self.images.count != 0 
			self.errors.add(:generic_errors, "There are images linked to this subreddit")
			return self 
		end

		self.destroy 
		
	end
 
  def get_latest_posts
     
    
    url = "http://www.reddit.com/r/#{self.name}/hot.json?limit=100&format=json"
    
    response = HTTParty.get( url )
     
    ActiveSupport::JSON.decode( response.body )
  end
  
  
  def update_posts
    indirect_link_array = []
    
    begin
      parsed_json = self.get_latest_posts  
      
      
      if parsed_json['data']['children'].length != 0 
        
      
       
        parsed_json['data']['children'].each do |post_data| 
          
          next if not Image.is_direct_image_link?(  post_data['data']['url'] )  
          
          Image.create_with_direct_image_link( self, post_data )  
          self.image_url = Image.order("id DESC").first.main_url
          self.save 
    
    
        end
      
      
      end
    rescue 
      puts $!, $@
      return nil
    end 
    
  end
  
  
end