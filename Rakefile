require 'rake/rdoctask'
require 'rake/packagetask'
require 'rake/testtask'

task :default => ['run']

desc "Run the application"
task :run do
  require 'init'
end

Rake::TestTask.new do |t|
  t.pattern = 'test/**/tc_*.rb'
end

# rake packae
# rake clobber_package
Rake::PackageTask.new('CodeLineStatistics', 1.0) do |p|
  p.need_tar_gz = true
  p.need_tar_bz2 = true
  p.need_zip = true
  Dir['**/*'].each do |path|
    p.package_files.include(path)
  end
end

# rake rdoc
Rake::RDocTask.new do |t|
  t.rdoc_dir = 'rdoc'
  t.rdoc_files.include('README', 'lib/**/*.rb')
  t.main = 'README'
  t.title = 'CodeLineStatistics API documentation'
end
