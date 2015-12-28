fat
===

C extension to find values in nested hashes without pain

The name is an acronym for "find at". It helps you avoid that nasty `undefined method [] for nil` when looking for values in a hash.

# Use

Say you have the following hash

```ruby
hash = {
  "foo" => {
    "bar" => {
      "baz" => :value
    }
  }
}
```

To get your `:value` you usually do `hash["foo"]["bar"]["baz"]`. But what happens if `"bar"` doesn't exist? Yeap, BOOM! You will get an `undefined method [] for nil` error.

Using `Fat` you can walk the hash up to the `:value`, but it'll raise an exception if it finds `nil` at any point.

```ruby
require "fat"

Fat.at(hash, "foo", "bar", "baz")
# => :value

Fat.at(hash, "foo", "not", "here")
# => Fat::FatError: foo.not is nil

Fat.at(hash, "foo", "bar", "nope")
# => Fat::FatError: foo.bar.nope is nil
```

You can specify a default return value with the `default:` keyword if you don't want an exception raised.

```ruby
require "fat"

Fat.at(hash, "foo", "not", "here", default: "whoops")
# => "whoops"
```

If you set `default: nil` this method behaves exactly like [Hash#dig](http://ruby-doc.org/core-2.3.0/Hash.html#method-i-dig), available from Ruby 2.3.0.

It's the same with Symbols

```ruby
hash = {
  "foo" => {
    :bar => {
      "baz" => :value
    }
  }
}

Fat.at(hash, "foo", :bar, "baz")
# => :value
```

If you prefer to call `hash.at` you only need to include `Fat` into `Hash`.

```ruby
Hash.include(Fat)

hash.at("foo", "bar", "baz")
# => :value
```

# Install

```bash
$ gem install fat
```

