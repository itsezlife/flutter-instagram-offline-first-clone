import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:instagram_blocks_ui/src/widgets/widgets.dart';
import 'package:octo_image/octo_image.dart';

class BlurHashImageThumbnail extends StatefulWidget {
  const BlurHashImageThumbnail({
    required this.url,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
    super.key,
    this.id,
    this.blurHash,
  });

  final String url;
  final String? blurHash;
  final String? id;
  final int? width;
  final int? height;
  final BoxFit? fit;

  @override
  State<BlurHashImageThumbnail> createState() => _BlurHashImageThumbnailState();
}

class _BlurHashImageThumbnailState extends State<BlurHashImageThumbnail> {
  late Key _key = ValueKey(widget.id ?? widget.url);

  void _resetKey() {
    setState(() => _key = ValueKey(DateTime.now()));
  }

  @override
  Widget build(BuildContext context) {
    return OctoImage.fromSet(
      key: _key,
      fit: widget.fit,
      memCacheHeight: widget.height,
      memCacheWidth: widget.width,
      image: CachedNetworkImageProvider(
        widget.url,
        maxWidth: 1080,
        maxHeight: 1080,
        cacheKey: widget.id == null ? widget.url : '${widget.id}/${widget.url}',
      ),
      octoSet: OctoBlurHashPlaceholder(
        blurHash: widget.blurHash,
        fit: widget.fit,
        height: widget.height?.toDouble(),
        width: widget.width?.toDouble(),
        onImageRefresh: _resetKey,
      ),
    );
  }
}
