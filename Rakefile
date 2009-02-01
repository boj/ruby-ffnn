require 'rake'
require 'rake/testtask'

task :default => [:test_units]

desc "Run basic network tests"
Rake::TestTask.new("test_units") { |t|
  t.pattern = 'unit/*_test.rb'
  t.verbose = true
  t.warning = true
}