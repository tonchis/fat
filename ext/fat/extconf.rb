require "mkmf"

dir_config("fat")

$CFLAGS += " -std=c99"

create_makefile("fat")
