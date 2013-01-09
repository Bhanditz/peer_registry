require File.dirname(__FILE__) + "/../pushes_processor"

namespace :sync do

  desc 'Process accepted pushes'
  task :process_pushes => :environment do
    while true
      puts "Checking for new pushes"
      EOL::PushesProcessor.process_pushes()
      puts "Sleeping for 10 seconds"
      sleep(10)
    end
  end

  desc 'Create an empty push as a start'
  task :create_empty_push => :environment do
    pr = PushRequest.new
    pr.success = 1
    pr.save
    
    sites = Site.all
    sites.each do |site|
      site.current_uuid = pr.uuid
      site.save
    end
  end
end