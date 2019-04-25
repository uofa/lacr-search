module SearchHelper
  def date_block_search(document)
    if document.date_incorrect
      document.date_incorrect
    elsif document.date_not_after
      "between #{document.date} and #{document.date_not_after}"
    else
      document.date
    end
  end
end
