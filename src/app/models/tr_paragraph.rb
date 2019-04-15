class TrParagraph < ApplicationRecord
  def print_data(documents)
    pdf = Prawn::Document.new
    documents.each do |document|
      # Get date and language
      date = document.date_incorrect ? document.date_incorrect : document.date
      lang = document.lang == "lat" ? "Latin" : document.lang == "sco" ? "Scots" : document.lang == "nld" ? "Dutch" : document.lang
      # Format the pdf content
      pdf.pad(10){ pdf.text "ID: #{document.entry}  Date: #{date}  Language: #{lang}" }
      pdf.pad(10){ pdf.text document.content}
      pdf.stroke_horizontal_rule
      pdf.move_down 30
    end
    # Create the file
    pdf.render
  end
end
