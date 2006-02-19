class RailsCron < ActiveRecord::Base
  cattr_accessor :options

  @@options = {
    :sleep => 1,
    :db_sleep => 60,
    :allow_concurrency => false
  }
  
  validates_presence_of :command, :start
  
  def self.start
    ENV.keys.each{|key| @@options[key.downcase.to_sym] = ENV[key]}
    
    ActiveRecord::Base.allow_concurrency = @@options[:allow_concurrency]
    
    unless @@options[:no_graceful]
      begin
        Signal.trap("USR1") do
          trace "RailsCron shutting down (Caught signal USR1)"
	      @@running = false 
        end
      rescue ArgumentError
        trace "RailsCron unsupported signal USR1"
      end
    end
    
    @@running = true
    threads = {}
    
		while @@running
  	  task_list.each do |job|
  	    if job.should_run_now
    	    key = (job.concurrent?) ? (Time.now.to_f + rand) : (job.command)
  	      threads[key] ||= Thread.new do
	          eval job.command
	          RailsCron.trace key, job.command
	        end
	      end
      end
		  threads = threads.delete_if{|key, value| !value.alive? }
			sleep @@options[:sleep]
		end		
		
		threads.each{|t| t.join}
	  RailsCron.trace "RailsCron ended gracefully"
	end	
	
	def self.trace(*args)
	  if @@options[:log]
	    File.open(File.join(File.expand_path(RAILS_ROOT), "log", "rails_cron.log"), "a") do |f| 
	      f.puts "#{Time.now}\t#{args.join "\t"}" 
      end
    end
  end
	
	def self.create_singleton(klass, method, options = {})
	  klass = eval klass.to_s
    method = method.to_s
    destroy_singleton klass.to_s, method
    
    sr = klass.read_inheritable_attribute(:cron_singleton_methods) ||
      klass.write_inheritable_attribute(:cron_singleton_methods, [])
    sr.push method.to_sym
    klass.write_inheritable_attribute :cron_singleton_methods, sr.uniq
    
    RailsCron.create(
      :command => wrap(klass.to_s, method),
      :start => (options[:start] || 0),
      :every => (options[:every] || 10),
      :finish => options[:finish],
      :concurrent => (options[:concurrent] || false)
    )
  end

  def self.execute_singleton(klass, method)
    klass = eval(klass.to_s)
    method = method.to_sym
    if klass.read_inheritable_attribute(:cron_singleton_methods).include? method
      klass.send method
    end
  end
    
  def self.destroy_singleton(klass, method)
    find_all_by_command(wrap(klass, method)).each{|i| i.destroy}
  end
  
  # Force db update before next command run
  def self.refresh
    @@last_db_update = 0
  end

  #Cast times to ints
  %w(start finish every).each do |i|
    class_eval <<-STR
      def #{i}=(arg);  self["#{i}"] = arg ? arg.to_i : nil ; end
    STR
  end
  
  def should_run_now
    now = Time.now.to_i
    return false if self.start && self.start > now
    return false if self.finish && self.finish < now
    
    start = self.start
    every = self.every || 1.day
    proximity = (now - start) % every
    return proximity < @@options[:sleep]
  end
  
protected

  def self.wrap(klass, method)
    "RailsCron.send :execute_singleton, :#{klass}, :#{method}"
  end
  
  def self.task_list
    @@last_db_update ||= 0
    if (Time.now.to_i - @@last_db_update) > @@options[:db_sleep]
      @@last_db_update = Time.now.to_i
      @@task_list = find(:all)
    else
      @@task_list
    end
  end
  
  def self.reloadable?; false end
end