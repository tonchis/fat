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
    exception = assert_raise(Fat::FatError) { Fat.at(hash, :foo, :bar, :found) }
    assert_equal "No hash found at foo.bar", exception.message

    assert_equal :found, Fat.at(hash, :foo, "bar", :baz)
  end
end

scope do
  test "single argument must be a namespace" do
    exception = assert_raise(Fat::FatError) { Fat.at({"foo" => "bar"}, "foo") }
    assert_equal "Single argument expected to be a namespace with dots (.) or colons (:)", exception.message
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

  test "namespaced strings" do |hash|
    assert_equal :found, Fat.at(hash, "foo.bar.baz")

    exception = assert_raise(Fat::FatError) { Fat.at(hash, "foo.not.baz") }
    assert_equal "No hash found at foo.not", exception.message
  end
end

scope do
  setup do
    {
      foo: {
        bar: {
          baz: :found
        }
      }
    }
  end

  test "namespaced symbols" do |hash|
    assert_equal :found, Fat.at(hash, "foo:bar:baz")

    exception = assert_raise(Fat::FatError) { Fat.at(hash, "foo:not:baz") }
    assert_equal "No hash found at foo.not", exception.message
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
    Hash.include(Fat)
  end

  test "corner case" do
    assert_raise(Fat::FatError) { {}.at(:foo, :bar) }
    assert_raise(Fat::FatError) { Fat.at({}, :foo, :bar) }
  end
end

