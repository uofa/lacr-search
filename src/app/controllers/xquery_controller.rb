require "#{Rails.root}/lib/BaseXClient"

class XqueryController < ApplicationController

  def index
  end

 def show
   begin
      # create session
      session = BaseXClient::Session.new(ENV['BASEX_URL'], 1984, "readOnly", ENV['BASEX_READONLY'])
      # session.create_readOnly()
      # Open DB or create if does not exist
      session.execute("open xmldb")
      # Get user query
      input = params[:search]
     # XQuery declaration of the namespace
      declarate_ns = 'declare namespace ns = "http://www.tei-c.org/ns/1.0";'
      # Create instance the BaseX Client in Query Mode
      query = session.query(declarate_ns + input)
      # Store the result
      @query_result = query.execute
      # Count the number of results
      @number_of_results = session.query("#{declarate_ns}count(#{input})").execute.to_i
      # close session
      query.close()
      session.close
    rescue Exception => e
      logger.error(e)
      @query_result = "--- Sorry, this query cannot be executed ---\n"+e.to_s
    end
  end
end
