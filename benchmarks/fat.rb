require "benchmark/ips"
require_relative "../lib/fat"

class Hash
  include Fat

  def ruby_at(*args, **keywords)
    value = self

    args.each_with_index do |field, index|
      value = value[field]
      if value.nil?
        if !keywords.empty?
          return keywords[:default]
        else
          raise Fat::FatError, "#{args[0..index].join(".")} is nil"
        end
      end
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

puts "### Small hash"
Benchmark.ips do |bench|
  bench.report("ruby") { hash.ruby_at("foo", "bar", "baz") }
  bench.report("c")    { hash.at("foo", "bar", "baz") }
  bench.compare!
end

# ### Small hash
# Calculating -------------------------------------
#                 ruby    46.836k i/100ms
#                    c    70.378k i/100ms
# -------------------------------------------------
#                 ruby    721.809k (± 4.2%) i/s -      3.606M
#                    c      1.401M (± 5.2%) i/s -      7.038M
#
# Comparison:
#                    c:  1400986.2 i/s
#                 ruby:   721809.1 i/s - 1.94x slower

puts "### Small hash: no value found."
Benchmark.ips do |bench|
  bench.report("ruby") { hash.ruby_at("foo", "one", "key") rescue Fat::FatError }
  bench.report("c")    { hash.at("foo", "one", "key") rescue Fat::FatError }
  bench.compare!
end

# ### Small hash: no value found.
# Calculating -------------------------------------
#                 ruby    20.762k i/100ms
#                    c    27.350k i/100ms
# -------------------------------------------------
#                 ruby    249.174k (± 3.6%) i/s -      1.246M
#                    c    338.960k (± 3.9%) i/s -      1.696M
#
# Comparison:
#                    c:   338959.9 i/s
#                 ruby:   249174.3 i/s - 1.36x slower

deep_hash = { "1" => {} }
2.upto(100) do |step|
  key = (1...step).to_a.map(&:to_s)
  current_hash = deep_hash.at(*key)
  current_hash[step.to_s] = {}
end

path_to_100 = 1.upto(100).to_a.map(&:to_s)

deep_hash.at(*path_to_100)["foo"] = :bar

path_to_foo = path_to_100 << "foo"

puts "### Deep hash"
Benchmark.ips do |bench|
  bench.report("ruby") { deep_hash.ruby_at(*path_to_foo) }
  bench.report("c")    { deep_hash.at(*path_to_foo) }
  bench.compare!
end

# ### Deep hash
# Calculating -------------------------------------
#                 ruby     4.856k i/100ms
#                    c    14.405k i/100ms
# -------------------------------------------------
#                 ruby     51.262k (± 3.7%) i/s -    257.368k
#                    c    162.600k (± 4.0%) i/s -    821.085k
#
# Comparison:
#                    c:   162600.4 i/s
#                 ruby:    51261.8 i/s - 3.17x slower

path_to_not = 1.upto(99).to_a.map(&:to_s)
path_to_not << "not"
path_to_not << "100"

puts "### Deep hash: no value found."
Benchmark.ips do |bench|
  bench.report("ruby") { deep_hash.ruby_at(*path_to_not) rescue Fat::FatError }
  bench.report("c")    { deep_hash.at(*path_to_not) rescue Fat::FatError }
  bench.compare!
end

# ### Deep hash: no value found.
# Calculating -------------------------------------
#                 ruby     2.883k i/100ms
#                    c     8.066k i/100ms
# -------------------------------------------------
#                 ruby     29.836k (± 4.1%) i/s -    149.916k
#                    c     86.900k (± 4.5%) i/s -    435.564k
#
# Comparison:
#                    c:    86899.9 i/s
#                 ruby:    29835.9 i/s - 2.91x slower

