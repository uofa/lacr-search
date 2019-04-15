class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  private
  def mobile?
  	request.user_agent =~ /Mobile|webOS/
  end

  def page_not_found
    raise ActionController::RoutingError.new('Not Found')
  end

  helper_method :mobile?
end
