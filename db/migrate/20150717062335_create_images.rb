class CreateImages < ActiveRecord::Migration
  def change
    create_table :images do |t|
 
      t.integer :sub_reddit_id 
    	t.string :content_url

    	t.string :reddit_url 
    	t.string :reddit_title
    	t.string :reddit_author
    	t.string :reddit_name 
    	t.string :main_url 
    	t.boolean :is_gif, :default => false 
    	
    	    	t.integer :year
    	t.integer :yday

      t.timestamps
    end
  end
end
