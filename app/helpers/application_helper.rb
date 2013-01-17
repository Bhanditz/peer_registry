module ApplicationHelper
  def send_processing_to_node(uuid, received_at)
    arr = {}
    arr[:success] = ''
    arr[:message] = 'processing'
    arr[:uuid] = uuid
    arr[:received_at] = received_at

    arr.to_json
  end

  def send_status_to_node(push_request)
    arr = {}
    arr[:success] = push_request.success
    arr[:success_at] = push_request.success_at if push_request.success == 1
    arr[:failed_at] = push_request.failed_at if push_request.success == 0
    arr[:failed_reason] = push_request.failed_reason if push_request.success == 0

    arr.to_json
  end
end