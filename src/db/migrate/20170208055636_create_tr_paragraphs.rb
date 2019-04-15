class CreateTrParagraphs < ActiveRecord::Migration[5.0]
  def change
    create_table :tr_paragraphs do |t|
      t.text :content_xml
      t.text :content_html
      t.integer :search_id
      t.timestamps
    end
  end
end
