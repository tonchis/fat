require "cutest"
require_relative "../lib/fat"

# The point of this test is to check for memory leaks.
# The idea is to run the test suite forever and monitor the process with `htop`
# to see if the memory consumption increases.

loop do
  Cutest.run_file(File.absolute_path("test/fat_test.rb"))
end

