import 'dart:ffi' as ffi;

class __llama_context extends ffi.Struct {
  external ffi.Pointer<ffi.Void> get rng;
  external set rng(ffi.Pointer<ffi.Void> value);

  external int get t_load_us;
  external set t_load_us(int value);

  external int get t_start_us;
  external set t_start_us(int value);

  external int get t_sample_us;
  external set t_sample_us(int value);

  external int get t_eval_us;
  external set t_eval_us(int value);

  external int get n_sample;
  external set n_sample(int value);

  external int get n_eval;
  external set n_eval(int value);
}

class NativeLibraryLLama {
  /// Holds the symbol lookup function.
  final ffi.Pointer<T> Function<T extends ffi.NativeType>(String symbolName)
      _lookup;

  /// The symbols are looked up in [dynamicLibrary].
  NativeLibraryLLama(ffi.DynamicLibrary dynamicLibrary)
      : _lookup = dynamicLibrary.lookup;

  /// The symbols are looked up with [lookup].
  NativeLibraryLLama.fromLookup(
      ffi.Pointer<T> Function<T extends ffi.NativeType>(String symbolName)
          lookup)
      : _lookup = lookup;
}
