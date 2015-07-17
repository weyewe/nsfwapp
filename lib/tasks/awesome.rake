
task :update_morning_posts => :environment do
    # Image.all.each {|x| x.destroy } 
    # SubReddit.all.each {|x| x.destroy } 
    # SubReddit.create_object( :name => "CumSluts")
    
    
    a = SubReddit.first 
    
    a.update_posts 
    
    puts "TOta image: #{Image.count}"
end
 
 
task :generate_sub_reddits => :environment do
    Image.all.each {|x| x.destroy } 
    SubReddit.all.each {|x| x.destroy } 
    
    ["aww","nsfw", "milf", "collegesluts", "O_faces", 
    "cumsluts", "nsfw_young", "drunkgonewild", "HappyEmbarrassedGirls", "drunkgirls", "PublicFlashing", "UnAshamed"].each do |name|
       a = SubReddit.create_object( :name =>  name ) 
       if not a.nil?
           puts "#{a.name} is available"
           a.update_posts 
           
           puts "image associated wih #{a.name}: #{a.images.count}"
       end
    end

    
     
end
 