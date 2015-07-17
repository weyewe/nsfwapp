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
    if not self.last_parsed_reddit_name.nil? and self.last_parsed_reddit_name.length != 0 
      puts "The one with last parsed"
      url = "http://www.reddit.com/r/#{self.name}/hot.json?limit=#{LIMIT_REDDIT}&before=#{last_parsed_reddit_name}&format=json"
    else
      puts "virgin shite"
      url = "http://www.reddit.com/r/#{self.name}/hot.json?limit=#{LIMIT_REDDIT}&format=json"
    end
    response = HTTParty.get( url )
     
    ActiveSupport::JSON.decode( response.body )
  end
  
  
  def update_posts
    begin
      parsed_json = self.get_latest_posts 
    
    
      if parsed_json['data']['children'].length != 0
        # update the last extracted reddit post 
        first_data = parsed_json['data']['children'].first
        self.last_parsed_reddit_name = first_data['data']['name'] 
        self.save 
      
      
        parsed_json['data']['children'].each do |post_data|
          next if Post.find_by_reddit_name( post_data['data']['name'])
          
          if Post.is_direct_image_link?(  post_data['data']['url'] )
            Post.create_with_direct_image_link( self, post_data ) 
          else
            Post.create_with_indirect_image_link( self, post_data )
          end
        end
      
      
      end
    rescue 
      return nil
    end
  end
end

=begin

SubReddit.create_object( :name => "aww")
	
=end