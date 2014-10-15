#include<ruby.h>

VALUE Fat = Qnil;
VALUE rb_eFatError = Qnil;

void Init_fat();

// Interface methods
static VALUE singleton_method_at(int argc, VALUE *argv, VALUE self);
static VALUE singleton_method_fetch_at(int argc, VALUE *argv, VALUE self);
static VALUE method_at(int argc, VALUE *argv, VALUE hash);
static VALUE method_fetch_at(int argc, VALUE *argv, VALUE hash);

static VALUE fat(VALUE hash, VALUE fields, int raise_on_nil);

// Helpers
static inline void parse_fields(VALUE args, VALUE *fields);
static inline VALUE fields_upto_index(VALUE fields, long index);
static inline void parse_singleton_args(int argc, VALUE *argv, VALUE *hash, VALUE *fields);
static inline void parse_method_args(int argc, VALUE *argv, VALUE *fields);

void Init_fat(void) {
  Fat = rb_define_module("Fat");
  rb_eFatError = rb_define_class_under(Fat, "FatError", rb_eStandardError);

  rb_define_module_function(Fat, "at", singleton_method_at, -1);
  rb_define_module_function(Fat, "fetch_at", singleton_method_fetch_at, -1);
  rb_define_method(Fat, "at", method_at, -1);
  rb_define_method(Fat, "fetch_at", method_fetch_at, -1);
}

static VALUE singleton_method_at(int argc, VALUE *argv, VALUE self) {
  VALUE hash;
  VALUE fields;

  parse_singleton_args(argc, argv, &hash, &fields);

  return fat(hash, fields, 0);
}

static VALUE singleton_method_fetch_at(int argc, VALUE *argv, VALUE self) {
  VALUE hash;
  VALUE fields;

  parse_singleton_args(argc, argv, &hash, &fields);

  return fat(hash, fields, 1);
}

static VALUE method_at(int argc, VALUE *argv, VALUE hash) {
  VALUE fields;

  parse_method_args(argc, argv, &fields);

  return fat(hash, fields, 0);
}

static VALUE method_fetch_at(int argc, VALUE *argv, VALUE hash) {
  VALUE fields;

  parse_method_args(argc, argv, &fields);

  return fat(hash, fields, 1);
}

static VALUE fat(VALUE hash, VALUE fields, int raise_on_nil) {
  VALUE value = hash;

  for (long i = 0; i < RARRAY_LEN(fields); i++) {
    value = rb_hash_aref(value, RARRAY_AREF(fields, i));

    if (i < RARRAY_LEN(fields) - 1 && TYPE(value) != T_HASH) {
      rb_raise(rb_eFatError, "No hash found at %s", RSTRING_PTR(fields_upto_index(fields, i)));
    }
  }

  return value;
}

static inline void parse_fields(VALUE args, VALUE *fields) {
  if (RARRAY_LEN(args) == 1) {
    *fields = rb_str_split(RARRAY_PTR(args)[0], ".");
  } else {
    *fields = args;
  }
}

static inline VALUE fields_upto_index(VALUE fields, long index) {
  VALUE range = rb_range_new(INT2FIX(0), INT2FIX(index), 0);
  VALUE slice = rb_funcall(fields, rb_intern("slice"), 1, range);
  return rb_ary_join(slice, rb_str_new2("."));
}

static inline void parse_singleton_args(int argc, VALUE *argv, VALUE *hash, VALUE *fields) {
  VALUE args;
  rb_scan_args(argc, argv, "1*", hash, &args);
  parse_fields(args, fields);
}

static inline void parse_method_args(int argc, VALUE *argv, VALUE *fields) {
  VALUE args;
  rb_scan_args(argc, argv, "*", &args);
  parse_fields(args, fields);
}
