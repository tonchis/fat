#include<ruby.h>

VALUE Fat = Qnil;

void Init_fat();
static VALUE singleton_method_at(int argc, VALUE *argv, VALUE self);
static VALUE module_method_at(int argc, VALUE *argv, VALUE hash);
static VALUE fat(VALUE hash, VALUE fields);

void Init_fat(void) {
  Fat = rb_define_module("Fat");
  rb_define_module_function(Fat, "at", singleton_method_at, -1);
  rb_define_method(Fat, "at", module_method_at, -1);
}

static VALUE singleton_method_at(int argc, VALUE *argv, VALUE self) {
  VALUE hash;
  VALUE args;

  rb_scan_args(argc, argv, "1*", &hash, &args);

  VALUE fields;
  if(RARRAY_LEN(args) == 1) {
    VALUE chain = RARRAY_PTR(args)[0];

    StringValue(chain);
    const char* dot = ".";

    fields = rb_str_split(chain, dot);
  } else {
    fields = args;
  }

  return fat(hash, fields);
}

static VALUE module_method_at(int argc, VALUE *argv, VALUE hash) {
  VALUE args;
  rb_scan_args(argc, argv, "*", &args);

  VALUE fields;
  if(RARRAY_LEN(args) == 1) {
    VALUE chain = RARRAY_PTR(args)[0];

    StringValue(chain);
    const char* dot = ".";

    fields = rb_str_split(chain, dot);
  } else {
    fields = args;
  }

  return fat(hash, args);
}

static VALUE fat(VALUE hash, VALUE fields) {
  VALUE value = hash;
  for (int i = 0; i < RARRAY_LEN(fields); i++) {
    value = rb_hash_aref(value, RARRAY_PTR(fields)[i]);

    if (!RTEST(value)) {
      return value;
    }
  }

  return value;
}


