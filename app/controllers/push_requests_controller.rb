class PushRequestsController < ApplicationController

  before_filter :set_response_format_to_json
  before_filter :authenticate_site, :only => [ :make_push ]
  before_filter :validate_current_uuid, :only => [ :make_push ]

  def make_push
    file_url = params[:file_url]
    file_md5_hash = params[:file_md5_hash]

    return render_error(400, 'Missing parameters') if file_url.blank? || file_md5_hash.blank?
    # check if the registry is processing another request.
    # in the future we may remove this check if needed.
    return render_error(405, 'Registry is busy') unless PushRequest.pending.empty?
    return render_error(409, 'Pull first') unless @site.up_to_date?

    push_request = PushRequest.new
    push_request.site_id = @site.id
    push_request.file_url = file_url
    push_request.file_md5_hash = file_md5_hash
    push_request.received_at = DateTime.now
    push_request.save

    @message = view_context.send_processing_to_node(push_request.uuid, push_request.received_at)
    render :json => @message
  end

  def query
    return render_error(400, 'Missing uuid') if params[:uuid].blank?

    push_request = PushRequest.find_by_uuid(params[:uuid])
    return render_error(401, 'Invalid uuid') unless push_request

    render :json => view_context.send_status_to_node(push_request)
  end
end
