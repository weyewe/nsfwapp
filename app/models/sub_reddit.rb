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
end
