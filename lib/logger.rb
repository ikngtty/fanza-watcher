class Logger
  def self.log(level, message)
    puts "[#{level}] (#{Time.now}) #{message}"
    $stdout.flush
  end

  def self.info(message)
    log('INFO', message)
  end

  def self.warn(message)
    log('WARN', message)
  end
end
