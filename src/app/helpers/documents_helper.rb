# Helper functions for displaying documents
module DocumentsHelper
  def date_block(document)
    date_str = '<strong>Date: </strong>'
    date_str += "<span class=\"cert-#{document.date_certainty}\">"
    if document.date_incorrect
      date_str += document.date_incorrect
    elsif document.date_not_after
      date_str += "between #{document.date} and #{document.date_not_after}"
    else
      date_str += "#{document.date}"
    end
    date_str + '<span>'
  end
end
