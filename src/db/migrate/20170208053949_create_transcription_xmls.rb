class CreateTranscriptionXmls < ActiveRecord::Migration[5.0]
  def change
    create_table :transcription_xmls do |t|
      t.jsonb :xml
      t.string :filename
      t.timestamps
    end
    add_index :transcription_xmls, :filename, unique: true  
  end
end
