build:
	rake compile
	cutest test/**/*_test.rb

benchmark:
	ruby benchmarks/fat.rb

.PHONY: build benchmark
