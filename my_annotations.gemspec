require 'rake'

Gem::Specification.new do |s|
  s.name        = 'my_annotations'
  s.version     = '0.6.0'
  s.date        = '2013-05-08'
  s.summary     = "This gem allows arbitrary metadata and relationships to be stored and retrieved, in the form of Annotations for any model objects in your Ruby on Rails (v2.2+) application."
  s.description = "This gem allows arbitrary metadata and relationships to be stored and retrieved, in the form of Annotations for any model objects in your Ruby on Rails (v2.2+) application."
  s.authors     = ["Jiten Bhagat","Stuart Owen","Quyen Nguyen"]
  s.email       = 'nttqa22001@yahoo.com'
  s.files       = `git ls-files`.split($/)
  s.homepage    = 'https://github.com/myGrid/annotations'
  s.require_paths = ["lib"]
end
