import 'dart:developer';

import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:octo_image/octo_image.dart';

class BlurHashImagePlaceholder extends StatelessWidget {
  const BlurHashImagePlaceholder({
    required this.blurHash,
    this.width,
    this.height,
    this.fit,
    this.withLoadingIndicator,
    this.indicatorColor,
    this.onImageRefresh,
    super.key,
  });

  final double? width;
  final double? height;
  final String? blurHash;
  final BoxFit? fit;
  final bool? withLoadingIndicator;
  final Color? indicatorColor;
  final VoidCallback? onImageRefresh;

  @override
  Widget build(BuildContext context) {
    if (blurHash == null || (blurHash?.isEmpty ?? true)) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }
    return Image(
      image: BlurHashImage(blurHash!),
      width: width,
      height: height,
      fit: BoxFit.cover,
      errorBuilder: (_, error, stackTrace) {
        log(
          'Error loading blur hash image: $blurHash',
          name: 'BlurHashImage',
          error: error,
        );
        return Tappable(
          onTap: onImageRefresh,
          child: OctoError.placeholderWithErrorIcon(
            (_) => const SizedBox.expand(),
          ).call(context, error, stackTrace),
        );
      },
    );
  }
}
