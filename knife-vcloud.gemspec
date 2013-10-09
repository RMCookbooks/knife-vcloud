Gem::Specification.new do |s|
  s.name = %q{knife-vcloud}
  s.version = "0.2.7"
  s.date = %q{2013-09-19}
  s.authors = ["Stefano Tortarolo"]
  s.email = ['stefano.tortarolo@gmail.com']
  s.summary = %q{A knife plugin for the VMWare vCloud API}
  s.homepage = %q{https://github.com/astratto/knife-vcloud}
  s.description = %q{A Knife plugin to create, list and manage vCloud servers}
  s.license     = 'Apache 2.0'

  s.add_dependency "chef", ">= 0.10.0"
  s.add_dependency "knife-windows", ">= 0"
  s.add_dependency "vcloud-rest", "0.3.5"
  s.require_path = 'lib'
  s.files = ["CHANGELOG.md","README.md", "LICENSE"] + Dir.glob("lib/**/*")
end
