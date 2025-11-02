// ignore_for_file: use_setters_to_change_properties
// ignore_for_file: avoid_positional_boolean_parameters

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker_plus/image_picker_plus.dart';
import 'package:image_picker_plus/src/camera_display.dart';
import 'package:image_picker_plus/src/images_view_page.dart';

final customImagePickerKey = GlobalKey<CustomImagePickerState>();

class CustomImagePicker extends StatefulWidget {
  const CustomImagePicker({
    required this.source,
    required this.multiSelection,
    required this.galleryDisplaySettings,
    required this.pickerSource,
    this.wantKeepAlive = true,
    this.onBackButtonTap,
    this.filterOption,
    super.key,
  });
  final ImageSource source;
  final bool multiSelection;
  final GalleryDisplaySettings? galleryDisplaySettings;
  final PickerSource pickerSource;
  final FilterOptionGroup? filterOption;
  final VoidCallback? onBackButtonTap;
  final bool wantKeepAlive;

  @override
  CustomImagePickerState createState() => CustomImagePickerState();
}

class CustomImagePickerState extends State<CustomImagePicker>
    with TickerProviderStateMixin {
  final pageController = PageController();
  final ValueNotifier<bool> clearVideoRecord = ValueNotifier(false);
  final ValueNotifier<bool> redDeleteText = ValueNotifier(false);
  final ValueNotifier<SelectedPage> selectedPage =
      ValueNotifier(SelectedPage.left);
  final ValueNotifier<List<File>> multiSelectedImages = ValueNotifier(<File>[]);
  final ValueNotifier<bool> multiSelectionMode = ValueNotifier(false);
  final ValueNotifier<bool> showDeleteText = ValueNotifier(false);
  final ValueNotifier<bool> selectedVideo = ValueNotifier(false);
  bool enableGallery = true;
  final selectedCameraImage = ValueNotifier<File?>(null);
  late bool cropImage;
  late AppTheme appTheme;
  late TabsTexts tabsNames;
  late bool showImagePreview;
  late int maximumSelection;
  final ValueNotifier<bool> isImagesReady = ValueNotifier(false);
  final ValueNotifier<int> currentPage = ValueNotifier(0);
  final ValueNotifier<int> lastPage = ValueNotifier(0);

  late GalleryDisplaySettings settings;

  late bool enableCamera;
  late bool enableVideo;
  late String limitingText;

  late bool showInternalVideos;
  late bool showInternalImages;
  late SliverGridDelegateWithFixedCrossAxisCount gridDelegate;
  late bool cameraAndVideoEnabled;
  late bool cameraVideoOnlyEnabled;
  late bool showAllTabs;
  late AsyncValueSetter<SelectedImagesDetails>? callbackFunction;

  @override
  void initState() {
    _initializeVariables();
    super.initState();
  }

  void _initializeVariables() {
    settings = widget.galleryDisplaySettings ?? const GalleryDisplaySettings();
    appTheme = settings.appTheme ?? const AppTheme();
    tabsNames = settings.tabsTexts ?? const TabsTexts();
    callbackFunction = settings.callbackFunction;
    cropImage = settings.cropImage;
    maximumSelection = settings.maximumSelection;
    limitingText = tabsNames.limitingText ??
        'The limit is $maximumSelection photos or videos.';

    showImagePreview = cropImage || settings.showImagePreview;
    gridDelegate = settings.gridDelegate;

    showInternalImages = widget.pickerSource != PickerSource.video;
    showInternalVideos = widget.pickerSource != PickerSource.image;

    enableGallery = widget.source != ImageSource.camera;
    final notGallery = widget.source != ImageSource.gallery;

    enableCamera = showInternalImages && notGallery;
    enableVideo = showInternalVideos && notGallery;
    cameraAndVideoEnabled = enableCamera && enableVideo;
    cameraVideoOnlyEnabled =
        cameraAndVideoEnabled && widget.source == ImageSource.camera;
    showAllTabs = cameraAndVideoEnabled && enableGallery;
  }

  void resetAll() {
    multiSelectedImages.value.clear();
    multiSelectionMode.value = false;
  }

  @override
  void dispose() {
    showDeleteText.dispose();
    selectedVideo.dispose();
    selectedPage.dispose();
    selectedCameraImage.dispose();
    pageController.dispose();
    clearVideoRecord.dispose();
    redDeleteText.dispose();
    multiSelectionMode.dispose();
    multiSelectedImages.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return tabController();
  }

  Widget tabBarMessage(bool isThatDeleteText) {
    final deleteColor = appTheme.onSurfaceColor;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: GestureDetector(
          onTap: () async {
            if (isThatDeleteText) {
              setState(() {
                if (!redDeleteText.value) {
                  redDeleteText.value = true;
                } else {
                  selectedCameraImage.value = null;
                  clearVideoRecord.value = true;
                  showDeleteText.value = false;
                  redDeleteText.value = false;
                }
              });
            }
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isThatDeleteText)
                Icon(
                  Icons.arrow_back_ios_rounded,
                  color: deleteColor,
                  size: 15,
                ),
              Text(
                isThatDeleteText ? tabsNames.deletingText : limitingText,
                style: TextStyle(
                  fontSize: 14,
                  color: deleteColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget clearSelectedImages() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: GestureDetector(
          onTap: () async {
            setState(() {
              multiSelectionMode.value = !multiSelectionMode.value;
              multiSelectedImages.value.clear();
            });
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                tabsNames.clearImagesText,
                style: TextStyle(
                  fontSize: 14,
                  color: appTheme.onSurfaceColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void replacingDeleteWidget(bool showDeleteText) {
    this.showDeleteText.value = showDeleteText;
  }

  void moveToVideo() {
    setState(() {
      selectedPage.value = SelectedPage.right;
      selectedVideo.value = true;
    });
  }

  DefaultTabController tabController() {
    return DefaultTabController(
      length: 2,
      child: Material(
        color: appTheme.surfaceColor,
        child: safeArea(),
      ),
    );
  }

  Widget safeArea() {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: PageView(
              controller: pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                if (enableGallery) imagesViewPage(),
                if (enableCamera || enableVideo) cameraPage(),
              ],
            ),
          ),
          if (multiSelectedImages.value.length < maximumSelection) ...[
            ValueListenableBuilder<bool>(
              valueListenable: multiSelectionMode,
              builder: (context, multiSelectionModeValue, child) {
                if (enableVideo || enableCamera) {
                  if (!showImagePreview) {
                    if (multiSelectionModeValue) {
                      return clearSelectedImages();
                    } else {
                      return buildTabBar();
                    }
                  } else {
                    return Visibility(
                      visible: !multiSelectionModeValue,
                      child: buildTabBar(),
                    );
                  }
                } else {
                  return multiSelectionModeValue
                      ? clearSelectedImages()
                      : const SizedBox();
                }
              },
            ),
          ] else ...[
            tabBarMessage(false),
          ],
        ],
      ),
    );
  }

  ValueListenableBuilder<bool> cameraPage() {
    return ValueListenableBuilder(
      valueListenable: selectedVideo,
      builder: (context, bool selectedVideoValue, child) => CustomCameraDisplay(
        appTheme: appTheme,
        selectedCameraImage: selectedCameraImage,
        tabsNames: tabsNames,
        enableCamera: enableCamera,
        enableVideo: enableVideo,
        replacingTabBar: replacingDeleteWidget,
        clearVideoRecord: clearVideoRecord,
        redDeleteText: redDeleteText,
        moveToVideoScreen: moveToVideo,
        selectedVideo: selectedVideoValue,
        callbackFunction: callbackFunction,
        onBackButtonTap: widget.onBackButtonTap,
      ),
    );
  }

  void clearMultiImages() {
    setState(() {
      multiSelectedImages.value.clear();
      multiSelectionMode.value = false;
    });
  }

  Widget imagesViewPage() {
    return ImagesViewPage(
      appTheme: appTheme,
      clearMultiImages: clearMultiImages,
      callbackFunction: callbackFunction,
      gridDelegate: gridDelegate,
      multiSelectionMode: multiSelectionMode,
      showImagePreview: showImagePreview,
      tabsTexts: tabsNames,
      multiSelectedMedia: multiSelectedImages,
      cropImage: cropImage,
      multiSelection: widget.multiSelection,
      showInternalVideos: showInternalVideos,
      showInternalImages: showInternalImages,
      maximumSelection: maximumSelection,
      filterOption: widget.filterOption,
      onBackButtonTap: widget.onBackButtonTap,
      pickAvatar: settings.pickAvatar,
      wantKeepAlive: widget.wantKeepAlive,
    );
  }

  ValueListenableBuilder<bool> buildTabBar() {
    return ValueListenableBuilder(
      valueListenable: showDeleteText,
      builder: (context, bool showDeleteTextValue, child) => AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        switchInCurve: Curves.easeInOutQuart,
        child: widget.source == ImageSource.both ||
                widget.pickerSource == PickerSource.both
            ? (showDeleteTextValue ? tabBarMessage(true) : tabBar())
            : const SizedBox(),
      ),
    );
  }

  Widget tabBar() {
    final widthOfScreen = MediaQuery.sizeOf(context).width;
    final divideNumber = showAllTabs ? 3 : 2;
    final widthOfTab = widthOfScreen / divideNumber;
    return ValueListenableBuilder(
      valueListenable: selectedPage,
      builder: (context, SelectedPage selectedPageValue, child) {
        final numOfTabs = !enableGallery && !enableCamera && !enableVideo
            ? 0
            : enableGallery && !enableCamera && !enableVideo ||
                    !enableGallery && enableCamera && !enableVideo ||
                    !enableGallery && !enableCamera && enableVideo
                ? 1
                : 2;
        final photoColor = selectedPageValue ==
                (numOfTabs == 3 ? SelectedPage.center : SelectedPage.right)
            ? appTheme.onSurfaceColor
            : appTheme.outlineColor;
        return Stack(
          alignment: Alignment.bottomLeft,
          children: [
            Row(
              children: [
                if (enableGallery) galleryTabBar(widthOfTab, selectedPageValue),
                if (enableCamera) photoTabBar(widthOfTab, photoColor),
                if (enableVideo) videoTabBar(widthOfTab),
              ],
            ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOutQuad,
              right: selectedPageValue == SelectedPage.center
                  ? widthOfTab
                  : (selectedPageValue == SelectedPage.right
                      ? 0
                      : (divideNumber == 2 ? widthOfTab : widthOfScreen / 1.5)),
              child: Container(
                height: 1,
                width: widthOfTab,
                color: appTheme.onSurfaceColor,
              ),
            ),
          ],
        );
      },
    );
  }

  GestureDetector galleryTabBar(
    double widthOfTab,
    SelectedPage selectedPageValue,
  ) {
    return GestureDetector(
      onTap: () {
        centerPage(numPage: 0, selectedPage: SelectedPage.left);
      },
      child: SizedBox(
        width: widthOfTab,
        height: 40,
        child: Center(
          child: Text(
            tabsNames.galleryText,
            style: TextStyle(
              color: selectedPageValue == SelectedPage.left
                  ? appTheme.onSurfaceColor
                  : appTheme.outlineColor,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  GestureDetector photoTabBar(double widthOfTab, Color textColor) {
    return GestureDetector(
      onTap: () => centerPage(
        numPage: cameraVideoOnlyEnabled ? 0 : 1,
        selectedPage:
            cameraVideoOnlyEnabled ? SelectedPage.left : SelectedPage.center,
      ),
      child: SizedBox(
        width: widthOfTab,
        height: 40,
        child: Center(
          child: Text(
            tabsNames.photoText,
            style: TextStyle(
              color: textColor,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  void centerPage({required int numPage, required SelectedPage selectedPage}) {
    if (!enableVideo && numPage == 1) selectedPage = SelectedPage.right;

    this.selectedPage.value = selectedPage;
    pageController.animateToPage(
      numPage,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutQuad,
    );
    selectedVideo.value = false;
  }

  GestureDetector videoTabBar(double widthOfTab) {
    return GestureDetector(
      onTap: () {
        pageController.animateToPage(
          cameraVideoOnlyEnabled ? 0 : 1,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOutQuad,
        );
        selectedPage.value = SelectedPage.right;
        selectedVideo.value = true;
      },
      child: SizedBox(
        width: widthOfTab,
        height: 40,
        child: ValueListenableBuilder(
          valueListenable: selectedVideo,
          builder: (context, bool selectedVideoValue, child) => Center(
            child: Text(
              tabsNames.videoText,
              style: TextStyle(
                fontSize: 14,
                color: selectedVideoValue
                    ? appTheme.onSurfaceColor
                    : appTheme.outlineColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
