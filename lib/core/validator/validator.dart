/// Marker implemented by every feature's validation-error enum, so
/// generic validator/failure plumbing can handle any feature's errors
/// without knowing their concrete type.
abstract interface class ValidationError {}

/// Contract every validator implements.
///
/// [T] is the value being checked (an Entity, usually), [E] is that
/// feature's own validation-error enum. Always returns *every* violated
/// rule, never just the first — callers decide how many to surface.
abstract interface class Validator<T, E extends ValidationError> {
  List<E> validate(T value);
}
