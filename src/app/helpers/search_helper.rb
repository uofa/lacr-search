module SearchHelper
  def search_result_header
    if @documents.total_count == 1
      'Showing 1 result'
    elsif @documents.total_count <= @results_per_page
      "Showing #{@documents.total_count} results"
    else
      (start_cnt, end_cnt) = page_range(@page, @results_per_page, @documents.total_count)
      "Showing #{start_cnt} to #{end_cnt} of #{@documents.total_count} results"
    end
  end

  def page_range(page, per_page, maximum)
    page_i = page ? page.to_i : 1

    s = ((page_i - 1) * per_page) + 1
    e = s + per_page - 1

    [[s, maximum].min, [e, maximum].min]
  end
end
