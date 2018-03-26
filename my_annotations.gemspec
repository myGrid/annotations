Gem::Specification.new do |s|
  s.name        = 'my_annotations'
  s.version     = '0.8.0'
  s.date        = '2018-03-26'
  s.summary     = "This gem allows arbitrary metadata and relationships to be stored and retrieved, in the form of Annotations for any model objects in your Ruby on Rails (v2.2+) application."
  s.description = "This gem allows arbitrary metadata and relationships to be stored and retrieved, in the form of Annotations for any model objects in your Ruby on Rails (v2.2+) application."
  s.authors     = ["Jiten Bhagat","Stuart Owen","Quyen Nguyen","Finn Bacall"]
  s.email       = 'seek4science@googlegroups.com'
  s.files       = `git ls-files`.split($/)
  s.homepage    = 'https://github.com/myGrid/annotations'
  s.require_paths = ["lib"]
end
