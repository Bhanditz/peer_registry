class ErrorsController < ApplicationController
  def error_404
    @not_found_path = params[:not_found]
    response.status = 404
  end

  def error_500
    response.status = 500
  end
end
