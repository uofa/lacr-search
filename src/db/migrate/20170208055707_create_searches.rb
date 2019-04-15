class CreateSearches < ActiveRecord::Migration[5.0]
  def change
    create_table :searches do |t|
      t.integer :tr_paragraph_id
      t.integer :transcription_xml_id

      t.string :entry
      t.string :lang

      t.integer :volume
      t.integer :page
      t.integer :paragraph

      t.text :content

      t.date :date
      t.string :date_incorrect # Used to explicity specify Date that was in incorrect format

      t.timestamps
    end
    add_index :searches, :volume
    add_index :searches, :page
    add_index :searches, :paragraph
    add_foreign_key :searches, :tr_paragraphs, on_delete: :cascade
    add_foreign_key :tr_paragraphs, :searches, on_delete: :cascade
    add_foreign_key :searches, :transcription_xmls
  end
end
