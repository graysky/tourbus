# =============================================================================
# A set of rake tasks for anansi crawling
# =============================================================================

desc "Bundle up the crawl, parse, and prepare import"
task :anansi_all => [:anansi_crawl, :anansi_parse, :anansi_prepare_import ]

# Each step can be put into testing mode by passing "true" to cstor
desc "Runs the 1st stage of the crawler"
task :anansi_crawl do

  # Can run like:
  # rake site=foo anansi_crawl
  # where foo is the *only* site to crawl
  site = ENV['site']
  testing = ENV['testing'] || false
  cmd = <<END
  c = AnansiConfig.new(#{testing}) 
  c.only_site = "#{site}"
  c.start
  c.crawl
END

  system "ruby ./script/runner '#{cmd}'"
end

desc "Runs the 2nd stage of the crawler"
task :anansi_parse do

  # Can run like:
  # rake site=foo anansi_parse
  # where foo is the *only* site to parse
  site = ENV['site']
  
  cmd = <<END
  p = AnansiParser.new()
  p.only_site = "#{site}"
  p.start
  p.parse
END

  system "ruby ./script/runner '#{cmd}'"
end

desc "Runs the 3rd stage of the crawler"
task :anansi_prepare_import do

  # Can run like:
  # rake site=foo anansi_prepare_import
  # where foo is the *only* site to parse
  site = ENV['site']
  
  cmd = <<END
  p = AnansiImporter.new()
  p.only_site = "#{site}"
  p.start
  p.prepare
END

  system "ruby ./script/runner '#{cmd}'"
end

desc "Runs the final stage of the crawler"
task :anansi_import do

  # TODO Remove "true" which indicates testing
  cmd = <<END
  p = AnansiImporter.new(true)
  p.start
  p.import
END

  system "ruby ./script/runner '#{cmd}'"
end


desc "Run anansi unit tests"
Rake::TestTask.new(:anansi_unit_tests) do |t|
  t.test_files = FileList['anansi/test/unit/test*.rb']
  t.verbose = true
end
