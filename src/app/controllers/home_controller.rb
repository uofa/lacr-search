class HomeController < ApplicationController
  def index
    @volumes = Search.select(:volume).distinct.order(volume: :asc).group(:volume)
  end
end
