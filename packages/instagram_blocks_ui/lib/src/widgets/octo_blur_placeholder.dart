import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:instagram_blocks_ui/src/blur_hash_image_placeholder.dart';
import 'package:octo_image/octo_image.dart';

class OctoBlurHashPlaceholder extends OctoSet {
  OctoBlurHashPlaceholder({
    required this.blurHash,
    this.fit,
    this.message,
    this.icon,
    this.iconColor,
    this.iconSize,
    double? width,
    double? height,
    VoidCallback? onImageRefresh,
  }) : super(
         placeholderBuilder: (_) => OctoBlurPlaceholderBuilder(
           blurHash: blurHash,
           fit: fit,
           height: height,
           width: width,
           onImageRefresh: onImageRefresh,
         ),
         errorBuilder: (context, error, stackTrace) => Tappable(
           onTap: onImageRefresh,
           child: _defaultBlurHashErrorBuilder(
             blurHash,
             height: height,
             width: width,
             fit: fit,
             message: message,
             icon: icon,
             iconColor: iconColor,
             iconSize: iconSize,
           ).call(context, error, stackTrace),
         ),
       );

  static OctoErrorBuilder _defaultBlurHashErrorBuilder(
    String? hash, {
    BoxFit? fit,
    Text? message,
    IconData? icon,
    Color? iconColor,
    double? iconSize,
    double? width,
    double? height,
  }) {
    return OctoError.placeholderWithErrorIcon(
      hash == null || hash.isEmpty
          ? OctoBlurPlaceholderBuilder.expandedSizedBox()
          : (_) => OctoBlurPlaceholderBuilder(
              blurHash: hash,
              fit: fit,
              height: height,
              width: width,
            ),
      message: message,
      icon: icon,
      iconColor: iconColor,
      iconSize: iconSize,
    );
  }

  final String? blurHash;
  final BoxFit? fit;
  final Text? message;
  final IconData? icon;
  final Color? iconColor;
  final double? iconSize;
}

class OctoBlurPlaceholderBuilder extends StatelessWidget {
  const OctoBlurPlaceholderBuilder({
    required this.blurHash,
    super.key,
    this.fit,
    this.width,
    this.height,
    this.withLoadingIndicator = false,
    this.onImageRefresh,
  });

  final String? blurHash;
  final BoxFit? fit;
  final double? width;
  final double? height;
  final bool withLoadingIndicator;
  final VoidCallback? onImageRefresh;

  static OctoPlaceholderBuilder circularProgressIndicator() =>
      (context) => const Center(
        child: CircularProgressIndicator.adaptive(),
      );

  static OctoPlaceholderBuilder expandedSizedBox() =>
      (context) => const SizedBox.expand();

  @override
  Widget build(BuildContext context) {
    return BlurHashImagePlaceholder(
      width: width,
      height: height,
      blurHash: blurHash,
      withLoadingIndicator: withLoadingIndicator,
      fit: fit,
      onImageRefresh: onImageRefresh,
    );
  }
}
