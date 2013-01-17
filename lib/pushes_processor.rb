require 'net/http'
require 'uri'
require 'socket'
require 'digest/md5'


module EOL
  class PushesProcessor
    def self.process_pushes
      push_requests = PushRequest.where('success is null')
      if push_requests.empty?
        puts "Nothing to process"
      else
        # Now start processing pushes
        puts "Processing pushes"
        push_requests.each do |push_request|
          process_push(push_request)
        end
      end
    end
    
    def self.process_push(request)
      file_url = Rails.root.join("log", "sync_logs", "#{request.id}")

      # download the log file, render :nothing => true if no success
      unless download_file?(request.file_url, "#{file_url}.json")
        report_failure(request, "Error downloading file: #{request.file_url}")
        return
      end

      # download the md5 file, render :nothing => true if no success
      unless download_file?(request.file_md5_hash, "#{file_url}.md5")
        report_failure(request, "Error downloading file: #{request.file_md5_hash}")
        return
      end

      # validate the md5 checksum
      unless validate_md5?("#{file_url}.json", "#{file_url}.md5")
        report_failure(request, "Invalid md5 checksum")
        return
      end 

      # Now, all checks are done. 
      # start importing data
      import_data(request)
      
      # update site uuid
      update_site_with_uuid(request.site_id, request.uuid)  
      
      # report success
      report_success(request)
    end

    def self.report_failure(request, message)
      request.success = 0
      request.failed_at = DateTime.now
      request.failed_reason = message
      request.save
    end

    def self.report_success(request)          
      request.success = 1
      request.success_at = DateTime.now
      request.save
    end
    
    def self.update_site_with_uuid(site_id, uuid)
      site = Site.find_by_id(site_id)
      site.current_uuid = uuid
      site.save
    end

    def self.download_file?(file_url, file_name)
      begin
        url = URI.parse(file_url)
        resp=Net::HTTP.get_response(url)
        open(file_name, 'wb') do |file|
          file.write resp.body
        end
        return true
      rescue
        return false
      end
    end

    def self.validate_md5?(file_url, mdf_file)
      data = File.read(file_url)
      md5_checksum = Digest::MD5.hexdigest(data)
      if (md5_checksum == File.read(mdf_file))
        return true
      else
        return false
      end
    end

    def self.import_data(request)
      file_url = Rails.root.join("log", "sync_logs", "#{request.id}.json")
      data = File.read(file_url)      
      data_json = JSON.parse(data)

      data_json.each do |data_element|
        peer_log = PeerLog.new
        peer_log.push_request_id = request.id
        peer_log.user_site_id = data_element["user_site_id"]
        peer_log.user_site_object_id = data_element["user_site_object_id"]
        peer_log.action_taken_at_time = data_element["action_taken_at_time"]
        peer_log.sync_object_action_id = SyncObjectAction.find_or_create_by_object_action(data_element["object_action"]).id
        peer_log.sync_object_type_id = SyncObjectType.find_or_create_by_object_type(data_element["object_type"]).id
        peer_log.sync_object_id = data_element["sync_object_id"]
        peer_log.sync_object_site_id = data_element["sync_object_site_id"]

        peer_log.save

        data_element["parameters"].each do |param|
          lap = LogActionParameter.new
          lap.peer_log_id = peer_log.id
          lap.param_object_id = param["param_object_id"]
          lap.param_object_site_id = param["param_object_site_id"]
          lap.parameter = param["parameter"]
          lap.value = param["value"]

          lap.save          
        end
      end
    end
  end
end