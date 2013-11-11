require 'rake'
require 'rake/testtask'

task :default => :integration_tests

# tests
def test(t, files)
  t.test_files = FileList.new(files)
  t.libs = %W(. test ..)
end

task :integration_tests do
  Rake::TestTask.new(:integration_tests) do |t|
    puts "Running integration tests"
    test(t, "test/integration/**/*_test.rb")
  end
end

