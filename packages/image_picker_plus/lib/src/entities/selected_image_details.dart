import 'dart:io';

import 'package:flutter/foundation.dart';

class SelectedImagesDetails {
  SelectedImagesDetails({
    required this.selectedFiles,
    required this.aspectRatio,
    required this.multiSelectionMode,
  });
  final List<SelectedByte> selectedFiles;
  final double aspectRatio;
  final bool multiSelectionMode;
}

class SelectedByte {
  SelectedByte({
    required this.isThatImage,
    required this.selectedFile,
    required this.selectedByte,
  });
  final File selectedFile;
  final Uint8List selectedByte;

  final bool isThatImage;
}
