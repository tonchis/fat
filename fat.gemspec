Gem::Specification.new do |s|
  s.name = "fat"
  s.version = "0.0.1"
  s.summary = "C extension to find values in nested hashes without pain"
  s.description = s.summary
  s.authors = ["Lucas Tolchinsky"]
  s.email = ["lucas.tolchinsky@gmail.com"]
  s.homepage = "https://github.com/tonchis/fat"
  s.license = "MIT"

  s.files = `git ls-files`.split("\n")
  s.extensions = ["ext/fat/extconf.rb"]

  s.add_development_dependency "cutest"
  s.add_development_dependency "rake-compiler"
end

