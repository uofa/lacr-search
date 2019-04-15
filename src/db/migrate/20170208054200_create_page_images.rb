class CreatePageImages < ActiveRecord::Migration[5.0]
  def change
    create_table :page_images do |t|
      t.jsonb :image
      t.integer :volume
      t.integer :page

      t.timestamps
    end
  end
end
