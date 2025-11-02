import 'dart:typed_data';

import 'package:blurhash/blurhash.dart';

/// {@template blur_hash_plus}
/// A package that manages blur hash.
/// {@endtemplate}
class BlurHashPlus {
  const BlurHashPlus._();

  /// Returns a [String] containing the blur hash of the image.
  static Future<String> blurHashEncode(Uint8List bytes) =>
      BlurHash.encode(bytes, 4, 3);
}
