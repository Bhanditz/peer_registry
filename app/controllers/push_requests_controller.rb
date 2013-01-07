class PushRequestsController < ApplicationController
  def make_push
    auth_code = params[:auth_code]
    current_uuid = params[:current_uuid]
    file_url = params[:file_url]
    file_md5_hash = params[:file_md5_hash]

    unless auth_code && current_uuid && file_url && file_md5_hash
      render_error('Missing Parameters') && return
    end

    # authenticate site
    site = Site.authenticate(auth_code)
    unless site
      render_error('Invalid auth_code') && return
    end

    # make sure that the site and the registry have the same UUID for this site 
    # TODO: if this check fails, then this node is out of sync. we need to figure out a procedure to fix this!
    unless (site.current_uuid == current_uuid)
      render_error('Invalid current_uuid') && return
    end

    # check if the registry is processing another request.
    # in the future we may remove this check if needed.
    if PushRequest.registry_is_busy?
      render_error('Registry is busy') && return
    end

    push_request = PushRequest.new
    push_request.site_id = site.id
    push_request.file_url = file_url
    push_request.file_md5_hash = file_md5_hash
    push_request.received_at = DateTime.now
    push_request.save 

    @message = view_context.send_processing_to_node(push_request.uuid, push_request.received_at)
    render :json => @message

  end

  def query
    uuid = params[:uuid]
    unless uuid
      render_error('Missing uuid') && return
    end

    push_request = PushRequest.find_by_uuid(uuid)
    unless push_request
      # invalid uuid
      render_error('Invalid uuid') && return
    end

    # render object
    render :json => view_context.send_status_to_node(push_request)
  end

  private

  def render_error(error_message)
    json_hash = {
      :success => 0,
      :message => error_message }
    render :json => json_hash.to_json, :status => 400
  end

end
