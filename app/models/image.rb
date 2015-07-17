require 'rubygems'
require 'nokogiri'
require 'open-uri'




class Image < ActiveRecord::Base

	belongs_to :sub_reddit
	validates_uniqueness_of :reddit_name

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
	
	def self.is_gif_url?(url)
		result  = url.match /\.gif/
		result_2 =  url.match /\.gifv/
		
		if result  or result_2
		  return true
		else
		  return false 
		end
	end
	
	def self.create_with_direct_image_link( sub_reddit_object , post_data ) 
		
 
    
    	new_object = self.new
    	new_object.sub_reddit_id   = sub_reddit_object.id 
		new_object.content_url		= post_data['data']['url']	
    	new_object.reddit_url 		= post_data['data']['permalink']	
    	new_object.reddit_title		= post_data['data']['title']
    	new_object.reddit_author	= post_data['data']['author']		
    	new_object.reddit_name 		= post_data['data']['name']		
    	new_object.main_url 		= post_data['data']['url']	
    	new_object.is_gif       	= self.is_gif_url?(post_data['data']['url'] ) 
    	new_object.yday = Date.today.yday().to_i
    	new_object.year = Date.today.year.to_i
    	
    	new_object.save 
    	
    	return new_object
	end
	
	
	def self.extract_image_url_from_indirect_link( url ) 
		begin
		  
		  page = Nokogiri::HTML(open(  url  ))  
		  
		  if url =~ /imgur.com/
		    
		    if( page.css("#image img").length != 0     ) 
	        	result = page.css("#image img")
		        images = result.map {|x| x['src'] }
		    	
		    	
		    elsif( page.css("#image-container").length == 0 )
		      if( page.css("#image").length != 0 )
		        result = page.css("#image img")
		        images = result.map {|x| x['src'] }
		      else
		        result = page.css("#content div.main-image img")
		        images = result.map {|x| x['src'] }
		      end 
		    else
		      result = page.css("#image-container img")
		      images = result.map {|x| x['data-src'] }
		    end
		    
		  elsif url =~ /weluvporn.com/
		    
		    if( page.css('.pictureImage img').length != 0  )
		      result = page.css('.pictureImage img')
		      images = result.map {|x| x['src'] }
		    else
		      result = page.css('#wlt-PictureOriginal img')
		      images = result.map {|x| x['src'] }
		    end
		
		  elsif url =~ /thefreefap.com/
		    
		    result = page.css('.pictureImage img')
		    images = result.map {|x| x['src'] }
		
		  elsif url =~ /subimg.net/
		    
		    result = page.css('img.magnify')
		    images = result.map {|x| x['src'] }
		    # 
		   
		  elsif url =~ /imgpo.st/
		    
		    result = page.css('#main img')
		    images = result.map {|x|   x['src'] } 
		   
		  elsif url =~ /imagebam.com/
		    
		    result = page.css('body img')
		    images = result.map {|x|   x['src'] } 
		    
		  elsif url =~ /x3e.com/
		    result = page.css('a img')
		    
		    if url =~ /index.php/
		      images = result.map do |x| 
		        puts "The source: #{x['src']}"
		        puts "The url: #{params[:url]}"
		        params[:url].gsub('index.php', x['src'])
		        # params[:url] + x['src']
		      end
		    else
		      images = result.map do |x| 
		        puts "The source: #{x['src']}"
		        puts "The url: #{params[:url]}"
		        # params[:url].gsub('index.php', x['src'])
		        params[:url] + x['src']
		      end
		    end
		    
		  end
		  
		  return images
		rescue
			puts "\n\nin the rescue block of image... "
			puts $!, $@
		  return []
		end
	end
	 
	
	def self.is_direct_image_link?(url)
		matching = url.match /\.(svg|jpe?g|png|gif|gifv)(?:[?#].*)?$|(?:imgur\.com)\/([^?#\/.]*)(?:[?#].*)?(?:\/)?$/ 
		  
		if (matching and matching[1])   # // normal image link
		  return true
		else
		  return false 
		end
		
	end
	
	def self.create_with_indirect_image_link( sub_reddit_object, post_data )
 
	    image_url_list = self.extract_image_url_from_indirect_link( post_data['data']['url'])
	    
	    if image_url_list.length == 0 
	    	puts "The nil url: #{post_data['data']['url']} "
	    	return
	    end
	   
	    
    	new_object = self.new
    	new_object.sub_reddit_id   = sub_reddit_object.id 
		new_object.content_url		= post_data['data']['url']	
    	new_object.reddit_url 		= post_data['data']['permalink']	
    	new_object.reddit_title		= post_data['data']['title']
    	new_object.reddit_author	= post_data['data']['author']		
    	new_object.reddit_name 		= post_data['data']['name']		
    	new_object.main_url 		= image_url_list.first 	
    	new_object.is_gif       	= self.is_gif_url?( image_url_list.first  )	
    	
    	new_object.save 
	    
	end
end
