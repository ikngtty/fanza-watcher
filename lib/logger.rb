class Logger
  def self.info(message)
    puts "[INFO] (#{Time.now}) #{message}"
    $stdout.flush
  end
end
