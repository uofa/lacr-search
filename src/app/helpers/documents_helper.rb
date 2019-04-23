module DocumentsHelper
  def date_block(document)
    date_str = '<strong>Date: </strong>'
    if document.date_incorrect
      date_str += "<span>#{document.date_incorrect}</span>"
    elsif document.date_not_after
      date_str += "<span>between #{document.date} and #{document.date_not_after}</span>"
    else
      date_str += "<span>#{document.date}</span>"
    end
    date_str
  end
end

