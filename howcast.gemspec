# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{howcast}
  s.version = "0.4.6"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jingshen Jimmy Zhang"]
  s.date = %q{2009-08-19}
  s.description = %q{Howcast API Ruby Wrapper}
  s.email = %q{jimmy@howcast.com}
  s.extra_rdoc_files = ["CHANGELOG", "lib/howcast/client/base.rb", "lib/howcast/client/category.rb", "lib/howcast/client/search.rb", "lib/howcast/client/video.rb", "lib/howcast/client.rb", "lib/howcast/errors.rb", "lib/howcast.rb", "README.markdown"]
  s.files = ["CHANGELOG", "lib/howcast/client/base.rb", "lib/howcast/client/category.rb", "lib/howcast/client/search.rb", "lib/howcast/client/video.rb", "lib/howcast/client.rb", "lib/howcast/errors.rb", "lib/howcast.rb", "License.txt", "Manifest", "Rakefile", "README.markdown", "spec/howcast/client/base_spec.rb", "spec/howcast/client/category_spec.rb", "spec/howcast/client/search_spec.rb", "spec/howcast/client/video_spec.rb", "spec/spec.opts", "spec/spec_helper.rb", "howcast.gemspec"]
  s.homepage = %q{http://github.com/howcast/howcast-gem}
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Howcast", "--main", "README.markdown"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{howcast}
  s.rubygems_version = %q{1.3.4}
  s.summary = %q{Howcast API Ruby Wrapper}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
