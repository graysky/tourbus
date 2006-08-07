# =============================================================================
# A set of rake tasks for dealing with solr indices.
# =============================================================================

namespace :solr do

  desc "Re-index the entire database - uses the current RAILS_ENV for which DB to index."
  task :reindex do
    cmd = <<END
      puts "Re-indexing bands..."
      Band.index_all
      puts "Re-indexing venues..."
      Venue.index_all
      puts "Re-indexing shows..."
      Show.index_all
END
    
    system "ruby ./script/runner '#{cmd}'"
  end
  
  desc "Start the solr seach server"
  task :start do
    puts "Starting solr..."
    
    cmd = <<END
      if ENV["RAILS_ENV"] == "development"
        Dir.chdir("../tourbus_search/server")
      else
        Dir.chdir("../../tourbus_search/server")
      end
      
      java_cmd = "java -Djava.util.logging.config.file=./solr/conf/logging.properties -jar start.jar"
      if ENV["RAILS_ENV"] == "development"
        system(java_cmd) 
      else
        system(java_cmd + " &") 
      end
END
  
    system "ruby ./script/runner '#{cmd}'"
  end
  
  desc "Stop the solr search server"
  task :stop do
    puts "Stopping solr..."
    cmd = <<END
      if ENV["RAILS_ENV"] == "development"
        Dir.chdir("../tourbus_search/server")
      else
        Dir.chdir("../../tourbus_search/server")
      end
      
      system("java -jar stop.jar")
END
  
    system "ruby ./script/runner '#{cmd}'"
  end
  
  desc "Bounce the solr search server"
  task :bounce do
    Rake::Task["solr:stop"].invoke
    Rake::Task["solr:start"].invoke
  end
  
  desc "Completely destroys the solr index"
  task :destroy_index do
    puts "Destroying the solr index..."
    cmd = <<END
      require "fileutils"
      FileUtils.rm_rf("../tourbus_search/server/solr/data/index")  
END
  
    system "ruby ./script/runner '#{cmd}'"
  end
  
end
