require "cutest"
require_relative "../lib/fat"

scope do
  setup do
    {
      foo: {
        "bar" => {
          baz: :found
        }
      }
    }
  end

  test "honor key type" do |hash|
    assert_equal nil, Fat.at(hash, "foo", :not, :found)
    assert_raise { Fat.fetch_at(hash, "foo", :not, :found) }

    assert_equal :found, Fat.at(hash, :foo, "bar", :baz)
    assert_equal :found, Fat.fetch_at(hash, :foo, "bar", :baz)
  end
end

scope do
  setup do
    {
      "foo" => {
        "bar" => {
          "baz" => :found
        }
      }
    }
  end

  test "namespaced string keys" do |hash|
    assert_equal nil, Fat.at(hash, "foo.not.found")
    assert_raise { Fat.fetch_at(hash, "foo.not.found") }

    assert_equal :found, Fat.at(hash, "foo.bar.baz")
    assert_equal :found, Fat.fetch_at(hash, "foo.bar.baz")
  end
end

scope do
  setup do
    Hash.include(Fat)
  end

  test "include the module" do
    assert Hash.new.respond_to?(:at)
  end

  test "honor Fat interface" do
    hash = {
      "foo" => {
        "bar" => {
          "baz" => :found
        }
      }
    }

    assert_equal :found, hash.at("foo", "bar", "baz")
    assert_equal :found, hash.at("foo.bar.baz")

    assert_equal :found, hash.fetch_at("foo", "bar", "baz")
    assert_equal :found, hash.fetch_at("foo.bar.baz")
  end
end

scope do
  setup do
    {
      "foo" => {
        "not_a_hash" => :wat,
        "bar" => {
          "baz" => :found
        }
      }
    }
  end

  test "break and return if a value is not a hash" do |hash|
    assert_equal :wat, Fat.at(hash, "foo.not_a_hash.baz")
    assert_equal :wat, Fat.fetch_at(hash, "foo.not_a_hash.baz")
  end
end

