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

  def get_reddit_url
    if not self.last_parsed_reddit_name.nil? and self.last_parsed_reddit_name.length != 0 
      puts "The one with last parsed"
      url = "http://www.reddit.com/r/#{self.name}/hot.json?limit=#{LIMIT_REDDIT}&before=#{last_parsed_reddit_name}&format=json"
    else
      puts "virgin shite"
      url = "http://www.reddit.com/r/#{self.name}/hot.json?limit=#{LIMIT_REDDIT}&format=json"
    end
    return url 
  end

  def get_latest_posts
    
    url  = self.get_reddit_url
    
    response = HTTParty.get( url )
     
    ActiveSupport::JSON.decode( response.body )
  end
  
  
  def update_posts
    indirect_link_array = []
    
    begin
      parsed_json = self.get_latest_posts 
      # puts "after parsed json.."
      # puts "#{parsed_json}"
      
      
    
      if parsed_json['data']['children'].length != 0
        # update the last extracted reddit post 
        first_data = parsed_json['data']['children'].first
        self.last_parsed_reddit_name = first_data['data']['name'] 
        self.save
        
        # puts "TOTal error: #{self.errors.size}"
        
      
      
        counter = 0 
        parsed_json['data']['children'].each do |post_data|
          
          # puts " #{counter}. checking name: #{ post_data['data']['name']} "
          
          counter = counter + 1 
          
          # next if not Image.find_by_reddit_name( post_data['data']['name']).nil? 
          
          initial_image_count  = Image.count 
          if Image.is_direct_image_link?(  post_data['data']['url'] )
            # puts "it is direct image link"
            
            Image.create_with_direct_image_link( self, post_data ) 
          else
            # puts "it is indirect image link"
            Image.create_with_indirect_image_link( self, post_data )
            # indirect_link_array <<   post_data['data']['url']
          end
          
          final_image_count = Image.count 
          if final_image_count == initial_image_count
            indirect_link_array <<  post_data['data']['url']
          end
        end
      
      
      end
    rescue 
      # puts $!, $@
      return nil
    end
    
  
    puts "link that are failed to be parsed:"
    # puts indirect_link_array
    
    
  end
  
  
end

=begin

SubReddit.create_object( :name => "aww")

Image.all.each {|x| x.destroy } 
a = SubReddit.first
a.last_parsed_reddit_name = nil
a.save 

a.update_posts 
=end