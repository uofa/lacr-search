class SearchController < ApplicationController

  def chart_wordstart_date
    if params[:term]
      # Strip white-space at the beginning and the end.
      query = params[:term].strip.gsub(/[^0-9a-z]/i, '')

      # Do not use autocomplete for phrases; The search method is not appropriate
      # if query.length < 20 and !query.include? ' '
         render json: (
          Search.search(query, {
             fields: ['content'], # Autocomplete for words in content
             match: :word_start, # Use word_start method
             highlight: {tag: "" ,
               fields: {content: {fragment_size: 0}}}, # Highlight only single word
            #  limit: 10, # Limit the number of results
             load: false, # Do not query the database (PostgreSQL)
             misspellings: {
               edit_distance: 1, # Limit misspelled distance to 1
               below: 4, # Do not use misspellings if there are more than 4 results
               transpositions: false # Show more accurate results
             }
           }
          # Get only the highlighted word
          # Remove non-aplhanumeric characters, such as white-space
          # Return only unique words
          ).pluck(:highlighted_content, :date, :entry)
           .delete_if{|content, date, entry| not content or not date or not entry}
           .collect{
             |content, date, entry| [
               content.gsub(/[^0-9a-z]/i, ''),
               '',
               "<span style=\"margin:5px;\"><b>ID:</b> #{entry}</span><br><span style=\"margin:5px;\"><b>Date:</b> #{date}</span>",
               date,
               date
               ]
             }
        )
       return # Finish here to avoid render {}
      # end
    end
    render json: {} # Render this if one of the 2 if statements fails
  end

  # Simple Search
  def search
    redirect_to doc_path if Search.count.zero? # Fix search on empty DB

    # Use strong params
    permited = simple_search_params

    # Parse Spelling variants and Results per page
    get_search_tools_params(permited)

    # Send the query to Elasticsearch
    if permited[:sm].to_i == 5
      @searchMethod = 5  # Regexp

        @documents = Search.search '*',
            page: permited[:page], per_page: @results_per_page, # Pagination
            where: {content:{"regexp":".*" + @query + ".*"}}.merge(get_adv_search_params(permited)),
            match: get_serch_method(permited), # Parse search method parameter
            order: get_order_by(permited), # Parse order_by parameter
            load: false # Do not retrieve data from PostgreSQL

    else
      @documents = Search.search @query,
          misspellings: {edit_distance: @misspellings,transpositions: false},
          page: permited[:page], per_page: @results_per_page, # Pagination
          where: get_adv_search_params(permited), # Parse adv search parameters
          match: get_serch_method(permited), # Parse search method parameter
          order: get_order_by(permited), # Parse order_by parameter
          highlight: {tag: "<mark>"}, # Set html tag for highlight
          fields: ['content'], # Search for the query only within content
          suggest: true, # Enable suggestions
          load: false # Do not retrieve data from PostgreSQL
    end
  end

  def autocomplete
    # Strip white-space at the beginning and the end.
    query = params[:term].strip.gsub(/[^0-9a-z]/i, '')

    # Do not use autocomplete for phrases; The search method is not appropriate
    if query.length < 20 and !query.include? ' '
       render json: (Search.search(query, {
         fields: ['content'], # Autocomplete for words in content
         match: :word_start, # Use word_start method
         highlight: {tag: "" ,
           fields: {content: {fragment_size: 0}}}, # Highlight only single word
         limit: 10, # Limit the number of results
         load: false, # Do not query the database (PostgreSQL)
         misspellings: {
           edit_distance: 1, # Limit misspelled distance to 1
           below: 4, # Do not use misspellings if there are more than 4 results
           transpositions: false # Show more accurate results
         }
       }
      # Get only the highlighted word
      # Remove non-aplhanumeric characters, such as white-space
      # Return only unique words
      ).map {|x| x.highlighted_content.gsub(/[^0-9a-z]/i, '')}).uniq
     else
       render json: {}
    end
   end

  def autocomplete_entry
     render json: Search.search(params[:term].strip, {
       fields: ['entry'],
       match: :word_start,
       limit: 5,
       load: false,
       misspellings: false
     }).map(&:entry)
   end

   # Define functions for simplicity
  private

  def simple_search_params
    params.permit(:q, :r, :m, :o, :sm, :entry, :date_from, :date_to, :v, :pg, :pr, :lang, :page)
  end

  def get_search_tools_params(permited)
    # Get text from the user input. In case of empty search -> use '*'
    @query = permited[:q].present? ? permited[:q].strip : '*'

    # Get the number of results per page; Default value -> 5
    @results_per_page = 5
    results_per_page = permited[:r].to_i
    if results_per_page >= 5 and results_per_page <= 50
      @results_per_page = results_per_page
    end

    # Get the misspelling distance; Default value -> 2
    @misspellings = 2
    misspellings = permited[:m].to_i
    if misspellings >= 0 and misspellings <= 5
      @misspellings = misspellings
    end
  end

  def get_order_by(permited)
    # Get the orderBy mode
    # 0 -> Most relevant first
    # 1 -> Volume/Page in ascending order
    # 2 -> Volume/Page in descending order
    # 3 -> Chronological orther
    @orderBy = permited[:o].to_i
    order_by = {}
    if @orderBy == 0
      order_by['_score'] = :desc # most relevant first - default
    elsif @orderBy == 1
      order_by['volume'] = :asc # volume ascending order
      order_by['page'] = :asc # page ascending order
    elsif @orderBy == 2
      order_by['volume'] = :desc # volume descending order
      order_by['page'] = :desc # page descending order
    elsif @orderBy == 3
      order_by['date'] = :asc
    end
    return order_by
  end

  def get_serch_method(permited)
    # Get the search method value
    # 0 -> Analyzed (Default)
    # 1 -> Phrase
    # 2 -> word_start
    # 3 -> word_middle
    # 4 -> word_end
    @searchMethod = permited[:sm].to_i

    case @searchMethod
      when 1 then search_method = :phrase
      when 2 then search_method = :word_start
      when 3 then search_method = :word_middle
      when 4 then search_method = :word_end
      else search_method = :analyzed
    end

    return search_method
  end

  def get_adv_search_params(permited)
    where_query = {}
    if permited[:entry] # Filter by Entry ID
      where_query['entry'] = Regexp.new "#{permited[:entry]}.*"
    end
    date_range = {}
    if permited[:date_from] # Filter by lower date bound
      begin
        date_str = permited[:date_from] # Get date
        # Fix incorrect date format
        case date_str.split('-').length
        when 3 then date_range[:gte] =  date_str.to_date
        when 2 then date_range[:gte] = "#{date_str}-1".to_date
        when 1 then date_range[:gte] = "#{date_str}-1-1".to_date
        else flash[:notice] = "Incorrect \"Date from\" format"
        end
      rescue
        flash[:notice] = "Incorrect \"Date from\" format"
      end
    end
    if permited[:date_to] # Filter by upper date bound
      begin
        date_str = permited[:date_to] # Get date
        # Fix incorrect date format
        case date_str.split('-').length
        when 3 then date_range[:lte] = date_str.to_date
        when 2 then date_range[:lte] = "#{date_str}-28".to_date
        when 1 then date_range[:lte] = "#{date_str}-12-31".to_date
        else  flash[:notice] = "Incorrect \"Date to\" format"
        end
      rescue
        flash[:notice] = "Incorrect \"Date to\" format"
      end
    end
    # Append to where_query
    where_query['date'] = date_range

    if permited[:lang] # Filter by language
      where_query['lang'] = permited[:lang]
    end
    if permited[:v] # Filter by voume
      where_query['volume'] = permited[:v].split(/,| /).map { |s| s.to_i }
    end
    if permited[:pg] # Filter by page
      where_query['page'] = permited[:pg].split(/,| /).map { |s| s.to_i }
    end
    if permited[:pr] # Filter by paragraph
      where_query['paragraph'] = permited[:pr].split(/,| /).map { |s| s.to_i }
    end
    return where_query
  end
end
