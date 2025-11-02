import 'package:shared/shared.dart';

/// Iterable extensions
extension IterableExtension<T> on Iterable<T> {
  /// Applies to each element in the iterable [toElement] function. If
  /// try catch block caught an error, it will be logged and null will be
  /// returned.
  Iterable<E?> safeNullableMap<E>(
    E Function(T element) toElement, {
    bool logError = true,
  }) => map((e) {
    try {
      return toElement(e);
    } catch (error, stackTrace) {
      if (logError) {
        logE('Error in safeMap.', error: error, stackTrace: stackTrace);
      }
      return null;
    }
  });

  /// Applies [toElement] function to each element in the iterable. If
  /// try catch block caught an error, it will be logged and null will be
  /// returned.
  ///
  /// Filters any nullable results and will return only non-nullable objects.
  Iterable<E> safeMap<E>(
    E Function(T element) toElement, {
    bool logError = true,
  }) sync* {
    for (final element in this) {
      try {
        yield toElement(element);
      } catch (error, stackTrace) {
        if (logError) {
          logE('Error in safeMap.', error: error, stackTrace: stackTrace);
        }
      }
    }
  }
}
