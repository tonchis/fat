require "benchmark/ips"
require_relative "../lib/fat"

class Hash
  include Fat

  def ruby_at(*args)
    fields = args.length == 1 ? args[0].split(".") : args
    value = self

    fields[0..-2].each_with_index do |field, index|
      value = value[field]
      raise Fat::FatError, "No hash found at #{fields[0..index].join(".")}" unless value.kind_of?(Hash)
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
  bench.report("ruby") { hash.ruby_at("foo.bar.baz.key") }
  bench.report("c")    { hash.at("foo.bar.baz.key") }
  bench.compare!
end

### String chain as a single argument.
# Calculating -------------------------------------
#                 ruby     37856 i/100ms
#                    c     47169 i/100ms
# -------------------------------------------------
#                 ruby   538803.8 (±7.3%) i/s -    2687776 in   5.026742s
#                    c   722313.8 (±7.2%) i/s -    3584844 in   5.006989s
#
# Comparison:
#                    c:   722313.8 i/s
#                 ruby:   538803.8 i/s - 1.34x slower


puts "### Each key as an argument."
Benchmark.ips do |bench|
  bench.report("ruby") { hash.ruby_at("foo", "bar", "baz") }
  bench.report("c")    { hash.at("foo", "bar", "baz") }
  bench.compare!
end

### Each key as an argument.
# Calculating -------------------------------------
#                 ruby     59783 i/100ms
#                    c     74832 i/100ms
# -------------------------------------------------
#                 ruby  1074906.7 (±3.1%) i/s -    5380470 in   5.010624s
#                    c  1590070.0 (±4.9%) i/s -    7932192 in   5.004163s
#
# Comparison:
#                    c:  1590070.0 i/s
#                 ruby:  1074906.7 i/s - 1.48x slower

puts "### No value found."
Benchmark.ips do |bench|
  bench.report("ruby") { hash.ruby_at("foo.one.key") rescue Fat::FatError }
  bench.report("c")    { hash.at("foo.one.key") rescue Fat::FatError }
  bench.compare!
end

### No value found.
# Calculating -------------------------------------
#                 ruby     17493 i/100ms
#                    c     18993 i/100ms
# -------------------------------------------------
#                 ruby   208018.1 (±4.9%) i/s -    1049580 in   5.060661s
#                    c   225204.0 (±5.1%) i/s -    1139580 in   5.074972s
#
# Comparison:
#                    c:   225204.0 i/s
#                 ruby:   208018.1 i/s - 1.08x slower

deep_hash = {}
1.upto(100) do |n|
  key = (1...n).to_a.join(".")
  current_hash = deep_hash.at(key)
  current_hash[n.to_s] = {}
end

path_to_100 = 1.upto(100).to_a.map(&:to_s)

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
#                 ruby      2549 i/100ms
#                    c      3633 i/100ms
# -------------------------------------------------
#                 ruby    27061.4 (±4.1%) i/s -     135097 in   5.002624s
#                    c    37773.5 (±3.0%) i/s -     188916 in   5.006074s
#
# Comparison:
#                    c:    37773.5 i/s
#                 ruby:    27061.4 i/s - 1.40x slower

puts "### Deep hash - Each key as an argument."
Benchmark.ips do |bench|
  bench.report("ruby") { deep_hash.ruby_at(*path_to_foo) }
  bench.report("c")    { deep_hash.at(*path_to_foo) }
  bench.compare!
end

### Deep hash - Each key as an argument.
# Calculating -------------------------------------
#                 ruby      4812 i/100ms
#                    c     14712 i/100ms
# -------------------------------------------------
#                 ruby    49779.4 (±5.1%) i/s -     250224 in   5.042241s
#                    c   168563.4 (±3.4%) i/s -     853296 in   5.068311s
#
# Comparison:
#                    c:   168563.4 i/s
#                 ruby:    49779.4 i/s - 3.39x slower

path_to_not = 1.upto(99).to_a.map(&:to_s)
path_to_not << "not"
path_to_not << "100"

puts "### Deep hash - No value found."
Benchmark.ips do |bench|
  bench.report("ruby") { deep_hash.ruby_at(*path_to_not) rescue Fat::FatError }
  bench.report("c")    { deep_hash.at(*path_to_not) rescue Fat::FatError }
  bench.compare!
end

### Deep hash - No value found.
# Calculating -------------------------------------
#                 ruby      2787 i/100ms
#                    c      8277 i/100ms
# -------------------------------------------------
#                 ruby    30667.8 (±1.3%) i/s -     156072 in   5.090009s
#                    c    86884.1 (±5.1%) i/s -     438681 in   5.064367s
#
# Comparison:
#                    c:    86884.1 i/s
#                 ruby:    30667.8 i/s - 2.83x slower

