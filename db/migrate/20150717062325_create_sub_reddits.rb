class CreateSubReddits < ActiveRecord::Migration
  def change
    create_table :sub_reddits do |t|
    	t.string :name
    	t.string :last_parsed_reddit_name 

      t.timestamps
    end
  end
end
