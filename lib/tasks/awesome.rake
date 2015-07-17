
task :update_morning_posts => :environment do
SubReddit.create_object( :name => "aww")

Image.all.each {|x| x.destroy } 
a = SubReddit.first
a.last_parsed_reddit_name = nil
a.save 

a.update_posts 

puts "TOta image: #{Image.count}"
end
 