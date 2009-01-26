# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{mos_eisley}
  s.version = "0.3.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Caroo GmbH"]
  s.date = %q{2009-01-26}
  s.default_executable = %q{mongrel_mos_eisley}
  s.description = %q{}
  s.email = ["dev@pkw.de"]
  s.executables = ["mongrel_mos_eisley"]
  s.extra_rdoc_files = ["History.txt", "Manifest.txt", "README.rdoc"]
  s.files = ["COPYING", "History.txt", "MIT-LICENSE", "Manifest.txt", "README.rdoc", "Rakefile", "bin/config.yml.example", "bin/mongrel_mos_eisley", "lib/mos_eisley.rb", "lib/mos_eisley/exceptions.rb", "lib/mos_eisley/handler.rb", "lib/mos_eisley/image.rb", "mos_eisley.gemspec", "test/assets/123456", "test/assets/adapter.yml", "test/handler_test.rb", "test/image_test.rb", "test/integration_test.rb", "test/mongrel_mos_eisley_test.rb", "test/mos_eisley_test.rb", "test/test_helper.rb"]
  s.has_rdoc = true
  s.homepage = %q{MosEisley is an mongrel-handler which serves images with thumbnail-generation from a persistence-adapter.}
  s.post_install_message = %q{PostInstall.txt}
  s.rdoc_options = ["--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{mos_eisley}
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{MosEisley is an mongrel-handler which serves images with thumbnail-generation from a persistence-adapter.}
  s.test_files = ["test/test_helper.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<mongrel>, [">= 0.3.10"])
      s.add_development_dependency(%q<mocha>, [">= 0"])
      s.add_development_dependency(%q<newgem>, [">= 1.2.3"])
      s.add_development_dependency(%q<hoe>, [">= 1.8.0"])
    else
      s.add_dependency(%q<mongrel>, [">= 0.3.10"])
      s.add_dependency(%q<mocha>, [">= 0"])
      s.add_dependency(%q<newgem>, [">= 1.2.3"])
      s.add_dependency(%q<hoe>, [">= 1.8.0"])
    end
  else
    s.add_dependency(%q<mongrel>, [">= 0.3.10"])
    s.add_dependency(%q<mocha>, [">= 0"])
    s.add_dependency(%q<newgem>, [">= 1.2.3"])
    s.add_dependency(%q<hoe>, [">= 1.8.0"])
  end
end
