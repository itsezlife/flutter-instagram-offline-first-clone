import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker_plus/image_picker_plus.dart';

class MultiSelectionMode extends StatelessWidget {
  const MultiSelectionMode({
    required this.appTheme,
    required this.image,
    required this.imageSelected,
    required this.multiSelectedImage,
    required this.multiSelectionMode,
    super.key,
  });
  final AppTheme appTheme;
  final ValueNotifier<bool> multiSelectionMode;
  final bool imageSelected;
  final List<File> multiSelectedImage;
  final File image;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: multiSelectionMode,
      builder: (context, bool multiSelectionModeValue, child) => Visibility(
        visible: multiSelectionModeValue,
        child: Align(
          alignment: Alignment.topRight,
          child: Padding(
            padding: const EdgeInsets.all(3),
            child: Container(
              height: 25,
              width: 25,
              decoration: BoxDecoration(
                color: imageSelected
                    ? appTheme.primaryContainerColor
                    : appTheme.outlineColor.withValues(alpha: 0.4),
                border: Border.all(color: appTheme.onSurfaceColor),
                shape: BoxShape.circle,
              ),
              child: imageSelected
                  ? Center(
                      child: Text(
                        '${multiSelectedImage.indexOf(image) + 1}',
                        style: TextStyle(color: appTheme.onSurfaceColor),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ),
        ),
      ),
    );
  }
}
