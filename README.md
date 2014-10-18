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

To get your `:value` you usually do `hash["foo"]["bar"]["baz"]`. But what happens if `"bar"` doesn't exist? Yeap, BOOM!

I find more comfortable to ask if I can walk to `:value` using the keys `"foo"`, `"bar"`, `"baz"`. If I can't, tell me where the path ends.

```ruby
require "fat"

Fat.at(hash, "foo", "bar", "baz")
# => :value

Fat.at(hash, "foo", "not", "here")
# => Fat::FatError: No hash found at foo.not
```

The `Fat::FatError` let's you know that a `Hash` was expected as a value for the key `"not"`. Way more explicit than guessing from a `undefined method [] for nil`.

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

If all your keys are Strings you can *namespace* them with dots.

```ruby
Hash.include(Fat)

hash.at("foo.bar.baz")
# => :value
```

# Install

```bash
$ gem install fat
```

