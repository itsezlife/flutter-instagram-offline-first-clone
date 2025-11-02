import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker_plus/src/custom_crop.dart';
import 'package:image_picker_plus/src/entities/app_theme.dart';
import 'package:image_picker_plus/src/entities/selected_image_details.dart';
import 'package:image_picker_plus/src/entities/tabs_texts.dart';
import 'package:image_picker_plus/src/utilities/enum.dart';
import 'package:image_picker_plus/src/utilities/extensions/file_extension.dart';
import 'package:image_picker_plus/src/video_layout/record_count.dart';
import 'package:image_picker_plus/src/video_layout/record_fade_animation.dart';
import 'package:insta_assets_crop/insta_assets_crop.dart';
import 'package:photo_manager/photo_manager.dart';

class CustomCameraDisplay extends StatefulWidget {
  const CustomCameraDisplay({
    required this.appTheme,
    required this.tabsNames,
    required this.selectedCameraImage,
    required this.enableCamera,
    required this.enableVideo,
    required this.redDeleteText,
    required this.selectedVideo,
    required this.replacingTabBar,
    required this.clearVideoRecord,
    required this.moveToVideoScreen,
    required this.callbackFunction,
    super.key,
    this.onBackButtonTap,
  });
  final bool selectedVideo;
  final AppTheme appTheme;
  final TabsTexts tabsNames;
  final bool enableCamera;
  final bool enableVideo;
  final VoidCallback moveToVideoScreen;
  final ValueNotifier<File?> selectedCameraImage;
  final ValueNotifier<bool> redDeleteText;
  final ValueChanged<bool> replacingTabBar;
  final ValueNotifier<bool> clearVideoRecord;
  final AsyncValueSetter<SelectedImagesDetails>? callbackFunction;
  final VoidCallback? onBackButtonTap;

  @override
  CustomCameraDisplayState createState() => CustomCameraDisplayState();
}

class CustomCameraDisplayState extends State<CustomCameraDisplay> {
  ValueNotifier<bool> startVideoCount = ValueNotifier(false);

  bool initializeDone = false;
  bool allPermissionsAccessed = true;
  bool _hasCamera = false;

  List<CameraDescription>? cameras;
  CameraController? controller;

  final cropKey = GlobalKey<CustomCropState>();

  Flash currentFlashMode = Flash.auto;
  late Widget videoStatusAnimation;
  int selectedCamera = 0;
  File? videoRecordFile;

  @override
  void dispose() {
    startVideoCount.dispose();
    controller?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    videoStatusAnimation = const SizedBox.shrink();
    _initializeCamera();

    super.initState();
  }

  Future<void> _initializeCamera() async {
    try {
      final state = await PhotoManager.requestPermissionExtend();
      if (!state.hasAccess || !state.isAuth) {
        allPermissionsAccessed = false;
        return;
      }
      allPermissionsAccessed = true;
      if (!mounted) return;
      cameras = await availableCameras();
      if (cameras == null || (cameras?.isEmpty ?? true)) {
        setState(() {
          _hasCamera = false;
          initializeDone = true;
        });
        return;
      }
      controller = CameraController(
        cameras![0],
        ResolutionPreset.high,
      );
      await controller?.initialize();
      initializeDone = true;
      _hasCamera = true;
    } catch (e) {
      allPermissionsAccessed = false;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: widget.appTheme.primaryColor,
      child: allPermissionsAccessed
          ? (initializeDone
              ? _hasCamera
                  ? buildBody()
                  : noCameraFound()
              : loadingProgress())
          : failedPermissions(),
    );
  }

  Widget failedPermissions() {
    return Stack(
      children: [
        appBar(withLeading: false),
        Align(
          child: Text(
            widget.tabsNames.acceptAllPermissions,
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.apply(color: widget.appTheme.onSurfaceColor),
          ),
        ),
      ],
    );
  }

  Widget noCameraFound() {
    return Stack(
      children: [
        appBar(withLeading: false),
        Align(
          child: Text(
            widget.tabsNames.noCameraFoundText,
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.apply(color: widget.appTheme.onSurfaceColor),
          ),
        ),
      ],
    );
  }

  Center loadingProgress() {
    return Center(
      child: CircularProgressIndicator(
        color: widget.appTheme.primaryColor,
        strokeWidth: 1,
      ),
    );
  }

  Widget buildBody() {
    final whiteColor = widget.appTheme.primaryColor;
    final selectedImage = widget.selectedCameraImage.value;
    return Column(
      children: [
        appBar(),
        Flexible(
          child: Stack(
            children: [
              if (selectedImage == null) ...[
                if (controller != null)
                  SizedBox(
                    width: double.infinity,
                    child: CameraPreview(controller!),
                  ),
              ] else ...[
                Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    color: whiteColor,
                    height: 360,
                    width: double.infinity,
                    child: buildCrop(selectedImage),
                  ),
                ),
              ],
              buildFlashIcons(),
              buildPickImageContainer(whiteColor, context),
            ],
          ),
        ),
      ],
    );
  }

  Align buildPickImageContainer(Color whiteColor, BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: 270,
        color: whiteColor,
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 1),
              child: Align(
                alignment: Alignment.topCenter,
                child: RecordCount(
                  appTheme: widget.appTheme,
                  startVideoCount: startVideoCount,
                  makeProgressRed: widget.redDeleteText,
                  clearVideoRecord: widget.clearVideoRecord,
                ),
              ),
            ),
            const Spacer(),
            Stack(
              alignment: Alignment.topCenter,
              children: [
                Container(
                  padding: const EdgeInsets.all(60),
                  child: Align(
                    child: cameraButton(context),
                  ),
                ),
                Positioned(bottom: 120, child: videoStatusAnimation),
              ],
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  Align buildFlashIcons() {
    return Align(
      alignment: Alignment.centerRight,
      child: IconButton(
        onPressed: () {
          setState(() {
            currentFlashMode = currentFlashMode == Flash.off
                ? Flash.auto
                : (currentFlashMode == Flash.auto ? Flash.on : Flash.off);
          });
          currentFlashMode == Flash.on
              ? controller?.setFlashMode(FlashMode.torch)
              : currentFlashMode == Flash.off
                  ? controller?.setFlashMode(FlashMode.off)
                  : controller?.setFlashMode(FlashMode.auto);
        },
        icon: Icon(
          currentFlashMode == Flash.on
              ? Icons.flash_on_rounded
              : (currentFlashMode == Flash.auto
                  ? Icons.flash_auto_rounded
                  : Icons.flash_off_rounded),
          color: Colors.white,
        ),
      ),
    );
  }

  CustomCrop buildCrop(File selectedImage) {
    final isThatVideo = selectedImage.isVideo;
    return CustomCrop(
      image: selectedImage,
      isThatImage: !isThatVideo,
      key: cropKey,
      alwaysShowGrid: true,
      paintColor: widget.appTheme.primaryColor,
    );
  }

  AppBar appBar({bool withLeading = true}) {
    final selectedImage = widget.selectedCameraImage.value;
    return AppBar(
      backgroundColor: widget.appTheme.surfaceColor,
      elevation: 0,
      title: Text(widget.tabsNames.newPostText),
      centerTitle: false,
      leading: IconButton(
        icon: Icon(
          Icons.clear_rounded,
          color: widget.appTheme.onSurfaceColor,
          size: 30,
        ),
        onPressed: () {
          if (widget.onBackButtonTap == null) {
            Navigator.of(context).maybePop();
          } else {
            widget.onBackButtonTap!.call();
          }
        },
      ),
      actions: !withLeading
          ? null
          : <Widget>[
              AnimatedSwitcher(
                duration: const Duration(seconds: 1),
                switchInCurve: Curves.easeIn,
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_forward_rounded,
                    color: widget.appTheme.primaryColor,
                    size: 30,
                  ),
                  onPressed: () async {
                    if (videoRecordFile != null) {
                      final byte = await videoRecordFile!.readAsBytes();
                      final selectedByte = SelectedByte(
                        isThatImage: false,
                        selectedFile: videoRecordFile!,
                        selectedByte: byte,
                      );
                      final details = SelectedImagesDetails(
                        multiSelectionMode: false,
                        selectedFiles: [selectedByte],
                        aspectRatio: 1,
                      );
                      if (!mounted) return;

                      void pop() => Navigator.of(context).maybePop(details);
                      if (widget.callbackFunction != null) {
                        await widget.callbackFunction!(details);
                      } else {
                        pop();
                      }
                    } else if (selectedImage != null) {
                      final croppedByte = await cropImage(selectedImage);
                      if (croppedByte != null) {
                        final byte = await croppedByte.readAsBytes();

                        final selectedByte = SelectedByte(
                          isThatImage: true,
                          selectedFile: croppedByte,
                          selectedByte: byte,
                        );

                        final details = SelectedImagesDetails(
                          selectedFiles: [selectedByte],
                          multiSelectionMode: false,
                          aspectRatio: 1,
                        );
                        if (!mounted) return;

                        void pop() => Navigator.of(context).maybePop(details);
                        if (widget.callbackFunction != null) {
                          await widget.callbackFunction!(details);
                        } else {
                          pop.call();
                        }
                      }
                    }
                  },
                ),
              ),
            ],
    );
  }

  Future<File?> cropImage(File imageFile) async {
    await InstaAssetsCrop.requestPermissions();
    final scale = cropKey.currentState!.scale;
    final area = cropKey.currentState!.area;
    if (area == null) {
      return null;
    }
    final sample = await InstaAssetsCrop.sampleImage(
      file: imageFile,
      preferredSize: (2000 / scale).round(),
    );
    final file = await InstaAssetsCrop.cropImage(
      file: sample,
      area: area,
    );
    await sample.delete();
    return file;
  }

  GestureDetector cameraButton(BuildContext context) {
    return GestureDetector(
      onTap: widget.enableCamera ? onPress : null,
      onLongPress: widget.enableVideo ? onLongTap : null,
      onLongPressUp: widget.enableVideo ? onLongTapUp : onPress,
      child: CircleAvatar(
        backgroundColor: widget.appTheme.outlineColor.withValues(alpha: 0.4),
        radius: 40,
        child: CircleAvatar(
          radius: 24,
          backgroundColor: widget.appTheme.onSurfaceColor,
        ),
      ),
    );
  }

  Future<void> onPress() async {
    try {
      if (!widget.selectedVideo) {
        final image = await controller?.takePicture();
        if (image == null) return;
        final selectedImage = File(image.path);
        setState(() {
          widget.selectedCameraImage.value = selectedImage;
          widget.replacingTabBar(true);
        });
      } else {
        setState(() {
          videoStatusAnimation = buildFadeAnimation();
        });
      }
    } catch (e) {
      if (kDebugMode) print(e);
    }
  }

  void onLongTap() {
    controller?.startVideoRecording();
    widget.moveToVideoScreen();
    setState(() {
      startVideoCount.value = true;
    });
  }

  Future<void> onLongTapUp() async {
    setState(() {
      startVideoCount.value = false;
      widget.replacingTabBar(true);
    });
    final video = await controller?.stopVideoRecording();
    if (video == null) return;
    videoRecordFile = File(video.path);
  }

  RecordFadeAnimation buildFadeAnimation() {
    return RecordFadeAnimation(child: buildMessage());
  }

  Widget buildMessage() {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            color: Color.fromARGB(255, 54, 53, 53),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              children: [
                Text(
                  widget.tabsNames.holdButtonText,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
        const Align(
          alignment: Alignment.bottomCenter,
          child: Center(
            child: Icon(
              Icons.arrow_drop_down_rounded,
              color: Color.fromARGB(255, 49, 49, 49),
              size: 65,
            ),
          ),
        ),
      ],
    );
  }
}
