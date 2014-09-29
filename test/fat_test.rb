require "cutest"
require_relative "../lib/fat"

setup do
  {
    "foo" => {
      "bar" => {
        "baz" => :found
      }
    }
  }
end

test "find values from a chain of keys" do |hash|
  assert_equal nil, Fat.at(hash, "foo.not.found")

  assert_equal :found, Fat.at(hash, "foo.bar.baz")
end

