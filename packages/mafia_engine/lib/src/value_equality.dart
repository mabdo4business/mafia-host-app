/// Structural equality for small immutable value types.
///
/// Lists compare in order, sets compare unordered.
abstract class ValueEquality {
  const ValueEquality();

  List<Object?> get props;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other.runtimeType == runtimeType && _deepEquals(props, (other as ValueEquality).props));

  @override
  int get hashCode => Object.hash(runtimeType, _deepHash(props));

  @override
  String toString() => '$runtimeType(${props.join(', ')})';
}

bool _deepEquals(Object? a, Object? b) {
  if (a is Set && b is Set) return a.length == b.length && a.containsAll(b);
  if (a is List && b is List) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (!_deepEquals(a[i], b[i])) return false;
    }
    return true;
  }
  return a == b;
}

int _deepHash(Object? o) {
  if (o is Set) return Object.hashAllUnordered(o.map(_deepHash));
  if (o is List) return Object.hashAll(o.map(_deepHash));
  return o.hashCode;
}
