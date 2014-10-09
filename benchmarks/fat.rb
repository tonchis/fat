require "benchmark/ips"
require_relative "../lib/fat"

class Hash
  include Fat

  def ruby_at(*args)
    fields = args.length == 1 ? args[0].split(".") : args
    value = self

    fields.each do |field|
      value = self[field]
      return unless value
      return value unless value.kind_of?(Hash)
    end

    value
  end
end

hash = {
  "foo" => {
    "bar" => {
      "baz" => {
        "key" => :value
      }
    }
  }
}

puts "### String chain as a single argument."
Benchmark.ips do |bench|
  bench.report("ruby") { hash.ruby_at("foo.bar.baz") }
  bench.report("c")    { hash.at("foo.bar.baz") }
  bench.compare!
end

### String chain as a single argument.
# Calculating -------------------------------------
#                 ruby     48558 i/100ms
#                    c     57683 i/100ms
# -------------------------------------------------
#                 ruby   749307.8 (±5.1%) i/s -    3738966 in   5.003814s
#                    c  1036251.6 (±4.2%) i/s -    5191470 in   5.019832s
#
# Comparison:
#                    c:  1036251.6 i/s
#                 ruby:   749307.8 i/s - 1.38x slower

puts "### Each key as an argument."
Benchmark.ips do |bench|
  bench.report("ruby") { hash.ruby_at("foo", "bar", "baz") }
  bench.report("c")    { hash.at("foo", "bar", "baz") }
  bench.compare!
end

### Each key as an argument.
# Calculating -------------------------------------
#                 ruby     58664 i/100ms
#                    c     72333 i/100ms
# -------------------------------------------------
#                 ruby  1056793.5 (±4.0%) i/s -    5279760 in   5.004811s
#                    c  1597827.5 (±2.6%) i/s -    8028963 in   5.028489s
#
# Comparison:
#                    c:  1597827.5 i/s
#                 ruby:  1056793.5 i/s - 1.51x slower

puts "### No value found."
Benchmark.ips do |bench|
  bench.report("ruby") { hash.ruby_at("foo.one.key") }
  bench.report("c")    { hash.at("foo.one.key") }
  bench.compare!
end

### No value found.
# Calculating -------------------------------------
#                 ruby     47999 i/100ms
#                    c     62238 i/100ms
# -------------------------------------------------
#                 ruby   762731.6 (±4.7%) i/s -    3839920 in   5.048382s
#                    c  1155802.0 (±4.3%) i/s -    5788134 in   5.019386s
#
# Comparison:
#                    c:  1155802.0 i/s
#                 ruby:   762731.6 i/s - 1.52x slower

deep_hash = {}
1.upto(100) do |n|
  key = (1...n).to_a.join(".")
  current_hash = deep_hash.at(key)
  current_hash[n.to_s] = {}
end

path_to_100 = 1.upto(100).to_a

deep_hash.at(path_to_100.join("."))["foo"] = :bar

path_to_foo = path_to_100 << "foo"

puts "### Deep hash - String chain argument."
Benchmark.ips do |bench|
  bench.report("ruby") { deep_hash.ruby_at(path_to_foo.join(".")) }
  bench.report("c")    { deep_hash.at(path_to_foo.join(".")) }
  bench.compare!
end

### Deep hash - String chain argument.
# Calculating -------------------------------------
#                 ruby      2221 i/100ms
#                    c      1993 i/100ms
# -------------------------------------------------
#                 ruby    22485.2 (±3.5%) i/s -     113271 in   5.044126s
#                    c    20166.9 (±5.9%) i/s -     101643 in   5.062351s
#
# Comparison:
#                 ruby:    22485.2 i/s
#                    c:    20166.9 i/s - 1.11x slower

puts "### Deep hash - Each key as an argument."
Benchmark.ips do |bench|
  bench.report("ruby") { deep_hash.ruby_at(*path_to_foo) }
  bench.report("c")    { deep_hash.at(*path_to_foo) }
  bench.compare!
end

### Deep hash - Each key as an argument.
# Calculating -------------------------------------
#                 ruby     60055 i/100ms
#                    c     72494 i/100ms
# -------------------------------------------------
#                 ruby  1107237.4 (±6.8%) i/s -    5525060 in   5.015326s
#                    c  1538256.4 (±9.4%) i/s -    7684364 in   5.044268s
#
# Comparison:
#                    c:  1538256.4 i/s
#                 ruby:  1107237.4 i/s - 1.39x slower

