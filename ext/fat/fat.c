#include<ruby.h>

VALUE Fat = Qnil;

void Init_fat();

// Interface methods
static VALUE singleton_method_at(int argc, VALUE *argv, VALUE self);
static VALUE singleton_method_fetch_at(int argc, VALUE *argv, VALUE self);
static VALUE method_at(int argc, VALUE *argv, VALUE hash);
static VALUE method_fetch_at(int argc, VALUE *argv, VALUE hash);

static VALUE fat(VALUE hash, VALUE fields, int raise_on_nil);

// Helpers
static void parse_fields(VALUE args, VALUE *fields);
static VALUE fields_upto_index(VALUE fields, int index);

void Init_fat(void) {
  Fat = rb_define_module("Fat");

  rb_define_module_function(Fat, "at", singleton_method_at, -1);
  rb_define_module_function(Fat, "fetch_at", singleton_method_fetch_at, -1);
  rb_define_method(Fat, "at", method_at, -1);
  rb_define_method(Fat, "fetch_at", method_fetch_at, -1);
}

static VALUE singleton_method_at(int argc, VALUE *argv, VALUE self) {
  VALUE hash;
  VALUE args;

  rb_scan_args(argc, argv, "1*", &hash, &args);

  VALUE fields;
  parse_fields(args, &fields);

  return fat(hash, fields, 0);
}

static VALUE singleton_method_fetch_at(int argc, VALUE *argv, VALUE self) {
  VALUE hash;
  VALUE args;

  rb_scan_args(argc, argv, "1*", &hash, &args);

  VALUE fields;
  parse_fields(args, &fields);

  return fat(hash, fields, 1);
}

static VALUE method_at(int argc, VALUE *argv, VALUE hash) {
  VALUE args;
  rb_scan_args(argc, argv, "*", &args);

  VALUE fields;
  parse_fields(args, &fields);

  return fat(hash, fields, 0);
}

static VALUE method_fetch_at(int argc, VALUE *argv, VALUE hash) {
  VALUE args;
  rb_scan_args(argc, argv, "*", &args);

  VALUE fields;
  parse_fields(args, &fields);

  return fat(hash, fields, 1);
}

static VALUE fat(VALUE hash, VALUE fields, int raise_on_nil) {
  VALUE value = hash;

  for (int i = 0; i < RARRAY_LEN(fields); i++) {
    VALUE key = RARRAY_PTR(fields)[i];
    value = rb_hash_aref(value, key);

    if (value == Qnil) {
      if (raise_on_nil == 1) {
        rb_raise(rb_eKeyError, "No value found at %s", RSTRING_PTR(fields_upto_index(fields, i)));
      } else {
        return Qnil;
      }
    }

    if (TYPE(value) != T_HASH) {
      return value;
    }
  }

  return value;
}

static void parse_fields(VALUE args, VALUE *fields) {
  if (RARRAY_LEN(args) == 1) {
    *fields = rb_str_split(RARRAY_PTR(args)[0], ".");
  } else {
    *fields = args;
  }
}

static VALUE fields_upto_index(VALUE fields, int index) {
  VALUE range = rb_range_new(INT2FIX(0), INT2FIX(index), 0);
  VALUE slice = rb_funcall(fields, rb_intern("slice"), 1, range);
  return rb_ary_join(slice, rb_str_new2("."));
}
