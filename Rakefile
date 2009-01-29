%w[rubygems rake rake/clean fileutils newgem rubigen].each { |f| require f }
require File.dirname(__FILE__) + '/lib/mos_eisley'

$hoe = Hoe.new('mos_eisley', MosEisley::VERSION) do |p|
  p.developer('Caroo GmbH', 'dev@pkw.de')
  # p.changes              = p.paragraphs_of("History.txt", 0..1).join("\n\n")
  p.extra_deps = [
    ['mongrel', '>= 0.3.10'],
    ['activesupport'],
    ["pkwde-renum"],
    ["pkwde-image_resizer"],
    ["pkwde-persistable"]
  ]
  p.extra_dev_deps = [
    ['mocha'],
    ['newgem', ">= #{::Newgem::VERSION}"]
  ]
  p.summary = "MosEisley is an mongrel-handler which serves images with thumbnail-generation from a persistence-adapter."
  p.clean_globs |= %w[**/.DS_Store tmp *.log]
  p.spec_extras = {:executables  => ['mongrel_mos_eisley']}
end

require 'newgem/tasks'

desc "Run tests"
Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
  t.test_files = FileList['test/*_test.rb']
  t.verbose = true
  t.warning = false
end

desc 'Generate RDoc'
Rake::RDocTask.new do |task|
  task.main = 'README.rdoc'
  task.title = "MosEisley #{MosEisley::VERSION}"
  task.rdoc_dir = 'doc'
  task.rdoc_files.include('README.rdoc', 'COPYING', 'MIT-LICENSE', "lib/*.rb")
end
