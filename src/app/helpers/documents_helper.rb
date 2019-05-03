# Helper functions for displaying documents
module DocumentsHelper
  def date_block(document)
    date_str = '<strong>Date: </strong>'
    date_str += "<span class=\"cert-#{document.date_certainty}\">"
    if document.date_incorrect
      date_str += document.date_incorrect
    elsif document.date_not_after
      # reset output to add helper class
      date_str = '<strong>Date: </strong>'
      date_str += "<span class=\"between cert-#{document.date_certainty}\">"
      date_str += "between #{document.date} and #{document.date_not_after}"
    else
      date_str += "#{document.date}"
    end
    date_str + '</span>'
  end
end
