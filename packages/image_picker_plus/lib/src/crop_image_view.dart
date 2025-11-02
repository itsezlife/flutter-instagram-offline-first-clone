import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker_plus/image_picker_plus.dart';
import 'package:image_picker_plus/src/custom_crop.dart';

class CropImageView extends StatefulWidget {
  const CropImageView({
    required this.indexOfSelectedImages,
    required this.cropKey,
    required this.multiSelectionMode,
    required this.expandImage,
    required this.expandHeight,
    required this.clearMultiImages,
    required this.expandImageView,
    required this.enableVerticalTapping,
    required this.selectedImage,
    required this.appTheme,
    required this.noDuration,
    required this.withMultiSelection,
    super.key,
    this.topPosition,
  });
  final GlobalKey<CustomCropState> cropKey;
  final ValueNotifier<List<int>> indexOfSelectedImages;

  final ValueNotifier<bool> multiSelectionMode;
  final ValueNotifier<bool> expandImage;
  final ValueNotifier<double> expandHeight;
  final ValueNotifier<bool> expandImageView;

  /// To avoid lag when you interacting with image when it expanded
  final ValueNotifier<bool> enableVerticalTapping;
  final ValueNotifier<File?> selectedImage;

  final VoidCallback clearMultiImages;

  final AppTheme appTheme;
  final ValueNotifier<bool> noDuration;
  final double? topPosition;
  final bool withMultiSelection;

  @override
  State<CropImageView> createState() => _CropImageViewState();
}

class _CropImageViewState extends State<CropImageView> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: widget.enableVerticalTapping,
      builder: (context, bool enableTappingValue, child) => GestureDetector(
        onVerticalDragUpdate: enableTappingValue && widget.topPosition != null
            ? (details) {
                widget.expandImageView.value = true;
                widget.expandHeight.value = details.globalPosition.dy - 56;
                setState(() => widget.noDuration.value = true);
              }
            : null,
        onVerticalDragEnd: enableTappingValue && widget.topPosition != null
            ? (details) {
                widget.expandHeight.value =
                    widget.expandHeight.value > 260 ? 360 : 0;
                if (widget.topPosition == -360) {
                  widget.enableVerticalTapping.value = true;
                }
                if (widget.topPosition == 0) {
                  widget.enableVerticalTapping.value = false;
                }
                setState(() => widget.noDuration.value = false);
              }
            : null,
        child: ValueListenableBuilder<File?>(
          valueListenable: widget.selectedImage,
          child: Container(key: GlobalKey(debugLabel: 'do not have')),
          builder: (context, selectedImage, _) {
            if (selectedImage != null) {
              return showSelectedImage(context, selectedImage);
            } else {
              return child!;
            }
          },
        ),
      ),
    );
  }

  Widget showSelectedImage(BuildContext context, File selectedImage) {
    final width = MediaQuery.sizeOf(context).width;
    return Container(
      color: widget.appTheme.onSurfaceColor,
      height: 360,
      width: width,
      child: ValueListenableBuilder<bool>(
        valueListenable: widget.multiSelectionMode,
        builder: (context, multiSelectionModeValue, child) => Stack(
          children: [
            ValueListenableBuilder<bool>(
              valueListenable: widget.expandImage,
              builder: (context, expandMedia, _) => CropPreview(
                selectedMedia: selectedImage,
                cropKey: widget.cropKey,
                expandMedia: expandMedia,
                paintColor: widget.appTheme.shimmerBaseColor,
              ),
            ),
            if (widget.topPosition != null) ...[
              if (widget.withMultiSelection)
                Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: GestureDetector(
                      onTap: () {
                        if (multiSelectionModeValue) {
                          widget.clearMultiImages();
                        }
                        setState(() {
                          widget.multiSelectionMode.value =
                              !multiSelectionModeValue;
                        });
                      },
                      child: Container(
                        height: 35,
                        width: 35,
                        decoration: BoxDecoration(
                          color: multiSelectionModeValue
                              ? widget.appTheme.primaryContainerColor
                              : widget.appTheme.shimmerBaseColor
                                  .withValues(alpha: 0.4),
                          border: Border.all(
                            color: widget.appTheme.onSurfaceColor,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child:
                              Icon(Icons.copy, color: Colors.white, size: 17),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class CropPreview extends StatelessWidget {
  const CropPreview({
    required this.selectedMedia,
    required this.cropKey,
    required this.paintColor,
    required this.expandMedia,
    super.key,
  });

  final File selectedMedia;
  final GlobalKey<CustomCropState> cropKey;
  final Color paintColor;
  final bool expandMedia;

  @override
  Widget build(BuildContext context) {
    return CustomCrop(
      key: cropKey,
      image: selectedMedia,
      isThatImage: !selectedMedia.isVideo,
      paintColor: paintColor,
      aspectRatio: expandMedia ? 4 / 5 : 1.0,
    );
  }
}
