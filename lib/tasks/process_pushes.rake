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
end