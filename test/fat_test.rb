require "cutest"
require_relative "../lib/fat"

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

  test "find value" do |hash|
    assert_equal :found, Fat.at(hash, "foo", "bar", "baz")
  end

  test "don't find value" do |hash|
    exception = assert_raise(Fat::FatError) { Fat.at(hash, "foo", "bar", "wat") }
    assert_equal "foo.bar.wat is nil", exception.message

    exception = assert_raise(Fat::FatError) { Fat.at(hash, "foo", "wat", "baz") }
    assert_equal "foo.wat is nil", exception.message
  end

  test "return default value" do |hash|
    assert_equal "default", Fat.at(hash, "foo", "wat", "baz", default: "default")
    assert_equal nil, Fat.at(hash, "foo", "bar", "wat", default: nil)
  end

  test "include the module" do |hash|
    Hash.include(Fat)

    assert hash.respond_to?(:at)
    assert_equal :found, hash.at("foo", "bar", "baz")

    exception = assert_raise(Fat::FatError) { hash.at("foo", "wat", "baz") }
    assert_equal "foo.wat is nil", exception.message

    assert_equal nil, hash.at("foo", "bar", "wat", default: nil)
  end
end

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
    exception = assert_raise(Fat::FatError) { Fat.at(hash, :foo, :bar, :found) }
    assert_equal "foo.bar is nil", exception.message

    assert_equal :found, Fat.at(hash, :foo, "bar", :baz)
  end
end

scope do
  setup do
    Hash.include(Fat)
  end

  test "corner case: empty hashes" do
    assert_raise(Fat::FatError) { {}.at(:foo, :bar) }
    assert_raise(Fat::FatError) { Fat.at({}, :foo, :bar) }
  end

  test "corner case: lookup a single key" do
    assert_equal :found, {"foo" => :found}.at("foo")
  end
end

