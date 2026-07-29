extension DoubleExtensions on double {
  /// Returns 0.0 if the value is NaN, Infinity, or -Infinity.
  double get safe => isFinite ? this : 0.0;
}

extension NullableDoubleExtensions on double? {
  /// Returns 0.0 if the value is null, NaN, Infinity, or -Infinity.
  double get safe {
    final value = this;
    return (value != null && value.isFinite) ? value : 0.0;
  }
}