build:
	rake compile
	cutest test/**/*_test.rb

.PHONY: build
