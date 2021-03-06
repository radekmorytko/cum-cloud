require 'rake'
require 'rake/testtask'

task :default => :unit_tests

# tests
def test(t, files)
  t.verbose = true
  #t.warning = true
  t.test_files = FileList.new(files)
  t.libs = %W(lib test ..)
end

task :unit_tests do
  Rake::TestTask.new(:unit_tests) do |t|
    puts "Running unit tests"
    test(t, "test/unit/**/*_test.rb")
  end
end

