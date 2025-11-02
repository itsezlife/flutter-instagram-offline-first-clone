import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gallery_media_picker/src/presentation/pages/gallery_media_picker_controller.dart';
import 'package:gallery_media_picker/src/presentation/widgets/select_album_path/dropdown.dart';
import 'package:gallery_media_picker/src/presentation/widgets/select_album_path/overlay_drop_down.dart';
import 'package:oktoast/oktoast.dart';
import 'package:photo_manager/photo_manager.dart';

class GalleryFunctions {
  static FeatureController<T> showDropDown<T>({
    required BuildContext context,
    required DropdownWidgetBuilder<T> builder,
    required TickerProvider tickerProvider,
    double? height,
    Duration animationDuration = const Duration(milliseconds: 250),
  }) {
    final animationController = AnimationController(
      vsync: tickerProvider,
      duration: animationDuration,
    );
    final completer = Completer<T?>();
    var isReply = false;
    OverlayEntry? entry;
    Future<void> close(T? value) async {
      if (isReply) {
        return;
      }
      isReply = true;
      animationController.animateTo(0).whenCompleteOrCancel(() async {
        await Future<void>.delayed(const Duration(milliseconds: 16));
        completer.complete(value);
        entry?.remove();
      });
    }

    /// overlay widget
    entry = OverlayEntry(
      builder: (context) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => close(null),
        child: OverlayDropDown(
          height: height!,
          close: close,
          animationController: animationController,
          builder: builder,
        ),
      ),
    );
    Overlay.of(context).insert(entry);
    animationController.animateTo(1);
    return FeatureController(
      completer,
      close,
    );
  }

  static void onPickMax(GalleryMediaPickerController provider) {
    provider.onPickMax
        .addListener(() => showToast('Already pick ${provider.max} items.'));
  }

  static Future<void> getPermission(
    void Function(void Function() fn)? setState,
    GalleryMediaPickerController provider,
  ) async {
    /// request for device permission
    final result = await PhotoManager.requestPermissionExtend();
    if (result.isAuth) {
      /// load "recent" album
      await provider.setAssetCount();
      await PhotoManager.startChangeNotify();
      PhotoManager.addChangeCallback((value) {
        _refreshPathList(setState, provider);
      });

      if (provider.pathList.isEmpty) {
        _refreshPathList(setState, provider);
      }
    } else {
      /// if result is fail, you can call `PhotoManager.openSetting();`
      /// to open android/ios application's setting to get permission
      await PhotoManager.openSetting();
    }
  }

  static void _refreshPathList(
    void Function(void Function() fn)? setState,
    GalleryMediaPickerController provider, {
    FilterOptionGroup? filterOption,
  }) {
    filterOption ??= FilterOptionGroup(
      videoOption: const FilterOption(
        durationConstraint: DurationConstraint(
          max: Duration(minutes: 3),
        ),
      ),
    );

    final type = provider.paramsModel?.onlyVideos ?? false
        ? RequestType.video
        : provider.paramsModel?.onlyImages ?? false
            ? RequestType.image
            : RequestType.image;
    PhotoManager.getAssetPathList(
      type: type,
      filterOption: filterOption,
    ).then((pathList) {
      /// don't delete setState
      Future.delayed(Duration.zero, () {
        setState?.call(() {
          provider.resetPathList(pathList);
        });
      });
    });
  }

  /// get asset path
  static Future<String> getFile(AssetEntity asset) async {
    final file = await asset.file;
    return file!.path;
  }
}

class FeatureController<T> {
  FeatureController(this.completer, this.close);
  final Completer<T?> completer;

  final ValueSetter<T?> close;

  Future<T?> get closed => completer.future;
}
