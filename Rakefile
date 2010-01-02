#
# File::      Rakefile
# Author::    wkm
# Copyright:: 2009, Zanoccio LLC.
# License::   GPL version 2.0 (see LICENSE.rb)
#
# Contains tasks for building gems and running tests.
#


require 'rubygems'
require 'rake/clean'
require 'rake/gempackagetask'

spec = Gem::Specification.new do |s|
  s.name       = 'sitefuel'
  s.version    = '0.1.0b'
  s.author     = 'wkm'
  s.email      = 'wkm@sitefuel.org'

  s.homepage   = 'http://sitefuel.org'
  s.platform   = Gem::Platform::RUBY
  s.summary    = 'A lightweight framework for processing, optimizing, and deploying websites'
  s.bindir     = 'bin'
  s.executables = ['sitefuel']
  s.default_executable = 'sitefuel'

  # for proper testing we need to include the .png and .jpg test images, they
  # double the size of the gem, however.
  s.files      = FileList["{bin,test,lib}/**/*"].exclude(".pxm", ".rdoc", ".sh").to_a
  
  s.require_path     = 'lib'
  s.test_file        = 'test/ts_all.rb'
  s.has_rdoc         = true
  s.extra_rdoc_files = ['README.rdoc', 'RELEASE_NOTES.rdoc']

  s.description = <<END
SiteFuel is a Ruby program and lightweight API for processing the source code
behind your static and dynamic websites. SiteFuel can remove comments and
unneeded whitespace from your CSS, HTML, and JavaScript files (as well as
fragments in RHTML and PHP) files. It can also losslessly compress your PNG and
JPEG images. SiteFuel can also deploy your website from SVN or GIT. Support for
more formats and repositories is planned for future versions. 
END


  # Gem dependencies
  s.add_dependency('hpricot', '>= 0.8')
  s.add_dependency('jsmin',   '>= 1.0')
  s.add_dependency('cssmin',  '>= 1.0')
  s.add_dependency('haml',    '>= 2.2')
  
  

  s.post_install_message = <<END
======================================================
 Thank you for installing SiteFuel 0.1.0.

 Please use caution when using this version of
 SiteFuel to deploy your websites. This should be
 considered an alpha release of SiteFuel and there
 may be bugs which will destroy your code.

 To get started see http://sitefuel.org/getstarted

 SiteFuel comes as an executable program:

  $ sitefuel --help
  $ sitefuel stage website_source
  $ sitefuel deploy website_source webserver_directory

 And also as a Ruby library:

  require 'rubygems'
  require 'sitefuel'

  runtime = SiteFuel::SiteFuelRuntime.new
  # ...

 If you're installing on Ubuntu you may need to adjust
 your $PATH environment variable for programs
 distributed with gems to work.
 (see http://sitefuel.org/ubuntu_installation)

=======================================================
END
  
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.need_tar = true
end

# get rid of temporary files generated by processor unit tests
CLEAN.include('**/tmp-*')

# when clobbering destroy any gems that were built
CLOBBER.include('pkg/*')


task :install do
  exec 'sudo gem install pkg/*.gem --no-ri --no-rdoc'
end

task :uninstall do
  exec 'sudo gem uninstall sitefuel'
end

task :reinstall => [:uninstall, :gem, :install]


task :doc do
  exec 'rdoc -U -d -a -S -N -p --include .'
end