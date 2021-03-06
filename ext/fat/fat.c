#include<ruby.h>

VALUE Fat = Qnil;
VALUE rb_eFatError = Qnil;

void Init_fat();

// Interface methods
static VALUE singleton_method_at(int argc, VALUE *argv, VALUE self);
static VALUE method_at(int argc, VALUE *argv, VALUE hash);

static VALUE fat(VALUE hash, VALUE fields, VALUE keywords);

// Helpers
static inline VALUE fields_upto_index(VALUE fields, long index);
static inline long compute_error_message_length(VALUE fields, long index);
static inline void copy_error_message(VALUE fields, long index, char* error_message_pointer);
static inline VALUE sym_to_str(VALUE sym);

void Init_fat(void) {
  Fat = rb_define_module("Fat");
  rb_eFatError = rb_define_class_under(Fat, "FatError", rb_eStandardError);

  rb_define_module_function(Fat, "at", singleton_method_at, -1);
  rb_define_method(Fat, "at", method_at, -1);
}

static VALUE singleton_method_at(int argc, VALUE *argv, VALUE self) {
  VALUE hash;
  VALUE fields;
  VALUE keywords;

  rb_scan_args(argc, argv, "1*:", &hash, &fields, &keywords);

  return fat(hash, fields, keywords);
}

static VALUE method_at(int argc, VALUE *argv, VALUE hash) {
  VALUE fields;
  VALUE keywords;

  rb_scan_args(argc, argv, "*:", &fields, &keywords);

  return fat(hash, fields, keywords);
}

static VALUE fat(VALUE hash, VALUE fields, VALUE keywords) {
  VALUE value = hash;

  for (long i = 0; i < RARRAY_LEN(fields); i++) {
    value = rb_hash_aref(value, RARRAY_AREF(fields, i));

    if (NIL_P(value)) {
      if (!NIL_P(keywords)) {
        return rb_hash_aref(keywords, ID2SYM(rb_intern("default")));
      } else {
        rb_raise(rb_eFatError, "%s is nil", RSTRING_PTR(fields_upto_index(fields, i)));
      }
    }
  }

  return value;
}

static inline VALUE fields_upto_index(VALUE fields, long index) {
  char error_message_pointer[compute_error_message_length(fields, index)];

  copy_error_message(fields, index, error_message_pointer);

  return rb_str_new2(error_message_pointer);
}

static inline long compute_error_message_length(VALUE fields, long index) {
  long error_length = 0;

  for (long j = 0; j <= index; j++) {
    VALUE field = RARRAY_AREF(fields, j);

    if (TYPE(field) == T_SYMBOL) {
      error_length += RSTRING_LEN(sym_to_str(field));
    } else {
      error_length += RSTRING_LEN(field);
    }

    // "." separator for the message.
    if (j != index) {
      error_length++;
    }
  }

  // The last character is '\0'.
  error_length++;

  return error_length;
}

static inline void copy_error_message(VALUE fields, long index, char* error_message_pointer) {
  char* current_char_pointer = error_message_pointer;

  for (long j = 0; j <= index; j++) {
    VALUE field = RARRAY_AREF(fields, j);

    long size;
    if (TYPE(field) == T_SYMBOL) {
      size = RSTRING_LEN(sym_to_str(field));
      memcpy(current_char_pointer, RSTRING_PTR(sym_to_str(field)), size);
    } else {
      size = RSTRING_LEN(field);
      memcpy(current_char_pointer, RSTRING_PTR(field), size);
    }

    current_char_pointer += size;

    if (j != index) {
      memcpy(current_char_pointer, ".", 1);
      current_char_pointer++;
    }
  }

  *current_char_pointer++ = '\0';
}

static inline VALUE sym_to_str(VALUE sym) {
  return rb_id2str(SYM2ID(sym));
}

