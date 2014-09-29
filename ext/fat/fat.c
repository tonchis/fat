#include<ruby.h>

VALUE Fat = Qnil;

void Init_fat();
static VALUE method_at(VALUE self, VALUE hash, VALUE chain);

void Init_fat(void) {
  Fat = rb_define_module("Fat");
  rb_define_singleton_method(Fat, "at", method_at, 2);
}

static VALUE method_at(VALUE self, VALUE hash, VALUE chain) {
  const char* dot = ".";
  StringValue(chain);
  VALUE fields = rb_str_split(chain, dot);

  VALUE value = hash;
  for(int i = 0; i < RARRAY_LEN(fields); i++) {
    value = rb_hash_aref(value, RARRAY_PTR(fields)[i]);

    if(value == Qnil) {
      return Qnil;
    }
  }

  return value;
}
