module TimeTracker
  class ProcessTimeTracker
    def self.track(description)
      start_time = Time.now
      puts "Starting: #{description} at #{start_time}"
      yield
      end_time = Time.now
      puts "Finished: #{description} at #{end_time}"
      puts "Total time elapsed: #{end_time - start_time} seconds"
    end
  end
end


