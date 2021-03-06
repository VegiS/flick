class Log
  
  attr_accessor :action, :platform, :driver, :udid
  
  def initialize options
    Flick::Checker.action options[:action]
    Flick::Checker.platform options[:platform]
    self.action = options[:action]
    self.platform = options[:platform]
    case @platform
    when "ios"
      options[:todir] = options[:outdir]
      self.driver = Flick::Ios.new options
    when "android"
      self.driver = Flick::Android.new options
    end
    self.udid = self.driver.udid
  end
  
  def run
    self.send(action)
  end
  
  def start
    puts "Saving to #{driver.outdir}/#{driver.name}.log"
    log
  end
  
  def stop
    Flick::System.kill_process "log", udid
  end
    
  def log
    stop
    $0 = "flick-log-#{udid}"
    SimpleDaemon.daemonize! "/tmp/#{udid}-pidfile"
    command = -> do
      driver.log driver.name
    end
   command.call
  end
end