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

# ### String chain as a single argument.
# Calculating -------------------------------------
#                 ruby     47304 i/100ms
#                    c     55888 i/100ms
# -------------------------------------------------
#                 ruby   741487.1 (±10.6%) i/s -    3642408 in   5.002662s
#                    c   977630.9 (±11.3%) i/s -    4806368 in   5.001422s
# Comparison:
#                    c:   977630.9 i/s
#                 ruby:   741487.1 i/s - 1.32x slower

puts "### Each key as an argument."
Benchmark.ips do |bench|
  bench.report("ruby") { hash.ruby_at("foo", "bar", "baz") }
  bench.report("c")    { hash.at("foo", "bar", "baz") }
  bench.compare!
end

# ### Each key as an argument.
# Calculating -------------------------------------
#                 ruby     57145 i/100ms
#                    c     73161 i/100ms
# -------------------------------------------------
#                 ruby  1035908.2 (±9.7%) i/s -    5143050 in   5.036346s
#                    c  1513478.5 (±11.1%) i/s -    7462422 in   5.017305s
# Comparison:
#                    c:  1513478.5 i/s
#                 ruby:  1035908.2 i/s - 1.46x slower

puts "### No value found."
Benchmark.ips do |bench|
  bench.report("ruby") { hash.ruby_at("foo.one.key") }
  bench.report("c")    { hash.at("foo.one.key") }
  bench.compare!
end

# ### No value found.
# Calculating -------------------------------------
#                 ruby     46842 i/100ms
#                    c     62515 i/100ms
# -------------------------------------------------
#                 ruby   733070.0 (±10.0%) i/s -    3653676 in   5.052594s
#                    c  1103249.9 (±11.2%) i/s -    5438805 in   5.026985s
# Comparison:
#                    c:  1103249.9 i/s
#                 ruby:   733070.0 i/s - 1.50x slower

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

# ### Deep hash - String chain argument.
# Calculating -------------------------------------
#                 ruby     35209 i/100ms
#                    c     37201 i/100ms
# -------------------------------------------------
#                 ruby   490384.6 (±10.9%) i/s -    2429421 in   5.040102s
#                    c   530276.4 (±10.0%) i/s -    2641271 in   5.057748s
# Comparison:
#                    c:   530276.4 i/s
#                 ruby:   490384.6 i/s - 1.08x slower

puts "### Deep hash - Each key as an argument."
Benchmark.ips do |bench|
  bench.report("ruby") { deep_hash.ruby_at(*path_to_foo) }
  bench.report("c")    { deep_hash.at(*path_to_foo) }
  bench.compare!
end

# ### Deep hash - Each key as an argument.
# Calculating -------------------------------------
#                 ruby     44009 i/100ms
#                    c     46413 i/100ms
# -------------------------------------------------
#                 ruby   674854.4 (±10.2%) i/s -    3344684 in   5.040045s
#                    c   734889.3 (±8.5%) i/s -    3666627 in   5.039101s
# Comparison:
#                    c:   734889.3 i/s
#                 ruby:   674854.4 i/s - 1.09x slower

