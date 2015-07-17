class Image < ActiveRecord::Base

	belongs_to :sub_reddit

	def self.create_object( params ) 
		new_object = self.new 

		new_object.content_url		= params[:content_url]		
    	new_object.reddit_url 		= params[:reddit_url]		
    	new_object.reddit_title		= params[:reddit_title]		
    	new_object.reddit_author	= params[:reddit_author]			
    	new_object.reddit_name 		= params[:reddit_name]			
    	new_object.main_url 		= params[:main_url]		
    	new_object.is_gif       	= params[:is_gif]			 

 

		new_object.save

		return new_object 
	end
end
