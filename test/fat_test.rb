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
    assert_raise(Fat::FatError) { Fat.at(hash, :foo, :not, :found) }

    assert_equal :found, Fat.at(hash, :foo, "bar", :baz)
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
    assert_raise(Fat::FatError) { Fat.at(hash, "foo", :not, :found) }

    assert_equal :found, Fat.at(hash, "foo.bar.baz")
  end
end

scope do
  setup do
    Hash.include(Fat)

    {
      "foo" => {
        "bar" => {
          "baz" => :found
        }
      }
    }
  end

  test "include the module" do |hash|
    assert hash.respond_to?(:at)
  end

  test "honor Fat interface" do |hash|
    assert_equal :found, hash.at("foo", "bar", "baz")
    assert_equal :found, hash.at("foo.bar.baz")
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

  test "raise error if a value is not a hash" do |hash|
    assert_raise(Fat::FatError) { Fat.at(hash, "foo.not_a_hash.baz") }
  end
end

scope do
  setup do
    Hash.include(Fat)
  end

  test "corner case" do
    assert_raise(Fat::FatError) { {}.at(:foo, :bar) }
    assert_raise(Fat::FatError) { Fat.at({}, :foo, :bar) }
  end
end
