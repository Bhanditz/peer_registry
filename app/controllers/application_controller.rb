class ApplicationController < ActionController::Base

  protect_from_forgery

  unless Rails.application.config.consider_all_requests_local
    rescue_from JSONException, with: lambda { |exception| render_error(500, exception) }
    rescue_from Exception, with: lambda { |exception| render_error(500, exception) }
    rescue_from ActionController::RoutingError, ActionController::UnknownController, ::AbstractController::ActionNotFound, ActiveRecord::RecordNotFound, with: lambda { |exception| render_error(404, exception) }
  end

  private

  def render_error(status, exception)
    respond_to do |format|
      format.html { render template: "errors/error_#{status}", layout: 'layouts/application', status: status, :locals => { :exception => exception } }
      format.json {
        json_hash = {
          :success => false,
          :message => exception.message }
        if exception.class != JSONException
          json_hash[:backtrace] = exception.backtrace
        end
        render :json => json_hash.to_json, :status => status
      }
      format.all { render template: "errors/error_#{status}", layout: 'layouts/application', status: status, :locals => { :exception => exception } }
    end
  end

  def set_response_format_to_json
    request.format = "json"
  end

  def authenticate_site
    raise JSONException.new('Missing auth_code') if params[:auth_code].blank?
    unless @site = Site.authenticate(params[:auth_code])
      raise JSONException.new('Invalid auth_code')
    end
  end

  def validate_current_uuid
    raise JSONException.new('Missing current_uuid') if params[:current_uuid].blank?
    # make sure that the site and the registry have the same UUID for this site
    # TODO: if this check fails, then this node is out of sync. we need to figure out a procedure to fix this!
    raise JSONException.new('Invalid current_uuid') unless @site.current_uuid == params[:current_uuid]
  end

end
