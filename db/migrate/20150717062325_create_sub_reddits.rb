class CreateSubReddits < ActiveRecord::Migration
  def change
    create_table :sub_reddits do |t|
    	t.string :name 
    	t.string :image_url


      t.timestamps
    end
  end
end
