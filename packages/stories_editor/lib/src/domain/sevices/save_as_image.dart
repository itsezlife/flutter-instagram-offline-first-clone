import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gal/gal.dart';
import 'package:native_exif/native_exif.dart';
import 'package:path_provider/path_provider.dart';
import 'package:stories_editor/src/presentation/utils/image_compress.dart';

/// Save network image to the photo library.
Future<bool> saveAttachmentToGallery(
  String path, {
  int index = 1,
  String relativePath = 'Instagram Clone',
}) async {
  if (kIsWeb) {
    return false;
  }

  // Generate Telegram-style filename: IMG_YYYYMMDD_HHMMSS_XXX.jpg
  final now = DateTime.now().add(Duration(seconds: index));
  final dateStr = now.year.toString().padLeft(4, '0') +
      now.month.toString().padLeft(2, '0') +
      now.day.toString().padLeft(2, '0');
  final timeStr = now.hour.toString().padLeft(2, '0') +
      now.minute.toString().padLeft(2, '0') +
      now.second.toString().padLeft(2, '0');
  final randomSuffix =
      (Random().nextInt(900) + 100).toString(); // 3-digit random number

  // final originalExtension = file.path.split('.').last.toLowerCase();
  // final extension = originalExtension.isNotEmpty ? originalExtension : 'jpg';
  final title = 'IMG_${dateStr}_${timeStr}_$randomSuffix';

  // 1) Write EXIF capture time to now
  final exif = await Exif.fromPath(path);
  String exifNow(String k) {
    // EXIF expects "YYYY:MM:DD HH:MM:SS"
    final y = now.year.toString().padLeft(4, '0');
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    final h = now.hour.toString().padLeft(2, '0');
    final mi = now.minute.toString().padLeft(2, '0');
    final s = now.second.toString().padLeft(2, '0');
    return '$y:$m:$d $h:$mi:$s';
  }

  await exif.writeAttributes({
    'DateTimeOriginal': exifNow('DateTimeOriginal'),
    'DateTimeDigitized': exifNow('DateTimeDigitized'),
    'DateTime': exifNow('DateTime'),
  });
  await exif.close();

  final data = await File(path).readAsBytes();

  // 2) Save by path so the system picks up EXIF and album
  await Gal.putImageBytes(data, name: title, album: relativePath);
  return true;
}

Future<dynamic> takePicture({
  required GlobalKey contentKey,
  required BuildContext context,
  required bool saveToGallery,
}) async {
  try {
    final boundary =
        contentKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;

    final image = await boundary?.toImage(pixelRatio: 3.0);

    final byteData = await image?.toByteData(format: ui.ImageByteFormat.png);
    final pngBytes = byteData?.buffer.asUint8List();
    final compressedBytes = await ImageCompress.compressByte(pngBytes);

    /// create file
    final dir = (await getApplicationDocumentsDirectory()).path;
    final imagePath = '$dir/${DateTime.now()}.png';
    final capturedFile = File(imagePath);
    await capturedFile.writeAsBytes(compressedBytes!);

    if (saveToGallery) {
      final result = await saveAttachmentToGallery(imagePath);
      return result;
    } else {
      return imagePath;
    }
  } catch (e) {
    return false;
  }
}
