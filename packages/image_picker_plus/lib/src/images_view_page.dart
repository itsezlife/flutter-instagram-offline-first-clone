import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker_plus/image_picker_plus.dart';
import 'package:image_picker_plus/src/crop_image_view.dart';
import 'package:image_picker_plus/src/custom_crop.dart';
import 'package:image_picker_plus/src/image.dart';
import 'package:image_picker_plus/src/multi_selection_mode.dart';
import 'package:insta_assets_crop/insta_assets_crop.dart';
import 'package:shimmer/shimmer.dart';

class ImagesViewPage extends StatefulWidget {
  const ImagesViewPage({
    required this.multiSelectedMedia,
    required this.multiSelectionMode,
    required this.clearMultiImages,
    required this.appTheme,
    required this.tabsTexts,
    required this.cropImage,
    required this.multiSelection,
    required this.showInternalVideos,
    required this.showInternalImages,
    required this.showImagePreview,
    required this.gridDelegate,
    required this.maximumSelection,
    required this.filterOption,
    required this.wantKeepAlive,
    super.key,
    this.callbackFunction,
    this.onBackButtonTap,
    this.pickAvatar = false,
  });
  final ValueNotifier<List<File>> multiSelectedMedia;
  final ValueNotifier<bool> multiSelectionMode;
  final TabsTexts tabsTexts;
  final bool cropImage;
  final bool multiSelection;
  final bool showInternalVideos;
  final bool showInternalImages;
  final int maximumSelection;
  final AsyncValueSetter<SelectedImagesDetails>? callbackFunction;
  final bool pickAvatar;

  /// To avoid lag when you interacting with image when it expanded
  final AppTheme appTheme;
  final VoidCallback clearMultiImages;
  final bool showImagePreview;
  final SliverGridDelegateWithFixedCrossAxisCount gridDelegate;
  final VoidCallback? onBackButtonTap;
  final bool wantKeepAlive;

  final FilterOptionGroup? filterOption;

  @override
  State<ImagesViewPage> createState() => _ImagesViewPageState();
}

class _ImagesViewPageState extends State<ImagesViewPage>
    with AutomaticKeepAliveClientMixin {
  late PMFilter _filterOption;

  final ValueNotifier<List<FutureBuilder<Uint8List?>>> _mediaList =
      ValueNotifier(<FutureBuilder<Uint8List?>>[]);

  final ValueNotifier<List<File?>> allMedia = ValueNotifier(<File?>[]);
  final ValueNotifier<List<double?>> scaleOfCropsKeys =
      ValueNotifier(<double?>[]);
  final ValueNotifier<List<Rect?>> areaOfCropsKeys = ValueNotifier(<Rect?>[]);

  final selectedMedia = ValueNotifier<File?>(null);
  final ValueNotifier<List<int>> indexOfSelectedMedia = ValueNotifier(<int>[]);

  final scrollController = ScrollController();

  final ValueNotifier<bool> expandMedia = ValueNotifier(false);
  final expandHeight = ValueNotifier<double>(0);
  final moveAwayHeight = ValueNotifier<double>(0);
  final ValueNotifier<bool> expandImageView = ValueNotifier(false);

  final ValueNotifier<bool> isMediaReady = ValueNotifier(false);
  final ValueNotifier<int> currentPage = ValueNotifier(0);
  final ValueNotifier<int> lastPage = ValueNotifier(0);

  /// To avoid lag when you interacting with image when it expanded
  final ValueNotifier<bool> enableVerticalTapping = ValueNotifier(false);
  final cropKey = GlobalKey<CustomCropState>();
  final ValueNotifier<bool> noPaddingForGridView = ValueNotifier(false);

  final scrollPixels = ValueNotifier<double>(0);
  final ValueNotifier<bool> isScrolling = ValueNotifier(false);
  final ValueNotifier<bool> noMedia = ValueNotifier(false);
  final ValueNotifier<bool> noDuration = ValueNotifier(false);
  final indexOfLatestMedia = ValueNotifier<int>(-1);

  AppTheme get appTheme => widget.appTheme;

  void resetAll() {
    selectedMedia.value = allMedia.value.isEmpty ? null : allMedia.value.first;
    widget.multiSelectedMedia.value.clear();
    widget.multiSelectionMode.value = false;
  }

  @override
  void dispose() {
    _mediaList.dispose();
    allMedia.dispose();
    scrollController.dispose();
    isMediaReady.dispose();
    lastPage.dispose();
    expandMedia.dispose();
    expandHeight.dispose();
    moveAwayHeight.dispose();
    expandImageView.dispose();
    enableVerticalTapping.dispose();
    noDuration.dispose();
    scaleOfCropsKeys.dispose();
    areaOfCropsKeys.dispose();
    indexOfSelectedMedia.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _applyFilerOption();

    _fetchNewMedia(currentPageValue: 0);
    super.initState();
  }

  void _applyFilerOption() {
    final newOption = FilterOptionGroup(
      imageOption: const FilterOption(
        sizeConstraint: SizeConstraint(ignoreSize: true),
      ),
      audioOption: const FilterOption(
        needTitle: true,
        sizeConstraint: SizeConstraint(ignoreSize: true),
      ),
      createTimeCond: DateTimeCond.def().copyWith(ignore: true),
      updateTimeCond: DateTimeCond.def().copyWith(ignore: true),
    );
    if (widget.filterOption != null) {
      newOption.merge(widget.filterOption!);
    }
    _filterOption = newOption;
  }

  bool _handleScrollEvent(
    ScrollNotification scroll, {
    required int currentPageValue,
    required int lastPageValue,
  }) {
    if (scroll.metrics.pixels / scroll.metrics.maxScrollExtent > 0.33 &&
        currentPageValue != lastPageValue) {
      _fetchNewMedia(currentPageValue: currentPageValue);
      return true;
    }
    return false;
  }

  Future<void> _fetchNewMedia({required int currentPageValue}) async {
    lastPage.value = currentPageValue;
    final result = await PhotoManager.requestPermissionExtend();
    if (result.isAuth) {
      final type = widget.showInternalVideos && widget.showInternalImages
          ? RequestType.common
          : (widget.showInternalImages ? RequestType.image : RequestType.video);

      final albums = await PhotoManager.getAssetPathList(
        onlyAll: true,
        type: type,
        filterOption: _filterOption,
      );
      if (albums.isEmpty) {
        WidgetsBinding.instance
            .addPostFrameCallback((_) => noMedia.value = true);
        return;
      } else if (noMedia.value) {
        noMedia.value = false;
      }

      final media = await albums[0].getAssetListPaged(
        page: currentPageValue,
        size: 60,
      );
      if (media.isEmpty) {
        WidgetsBinding.instance
            .addPostFrameCallback((_) => noMedia.value = true);
        return;
      }
      final temp = <FutureBuilder<Uint8List?>>[];
      final mediaTemp = <File?>[];

      for (var i = 0; i < media.length; i++) {
        final gridViewImage = getImageGallery(media, i);
        final image = await highQualityImage(media, i);
        temp.add(gridViewImage);
        mediaTemp.add(image);
      }
      _mediaList.value.addAll(temp);
      allMedia.value.addAll(mediaTemp);
      if (selectedMedia.value == allMedia.value[0] ||
          selectedMedia.value == null) {
        selectedMedia.value = allMedia.value[0];
      }
      currentPage.value++;
      isMediaReady.value = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
    } else {
      await PhotoManager.requestPermissionExtend();
      await PhotoManager.openSetting();
    }
  }

  FutureBuilder<Uint8List?> getImageGallery(List<AssetEntity> media, int i) {
    final highResolution = widget.gridDelegate.crossAxisCount <= 3;
    final futureBuilder = FutureBuilder<Uint8List?>(
      future: media[i].thumbnailDataWithSize(
        highResolution
            ? const ThumbnailSize(350, 350)
            : const ThumbnailSize(200, 200),
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          final image = snapshot.data;
          if (image != null) {
            return ColoredBox(
              color: const Color.fromARGB(255, 189, 189, 189),
              child: Stack(
                children: <Widget>[
                  Positioned.fill(
                    child: MemoryImageDisplay(
                      imageBytes: image,
                      appTheme: widget.appTheme,
                    ),
                  ),
                  if (media[i].type == AssetType.video) ...[
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 2, bottom: 2),
                        child: VideoThumbnailFooter(asset: media[i]),
                      ),
                    ),
                  ],
                ],
              ),
            );
          }
        }
        return const SizedBox();
      },
    );
    return futureBuilder;
  }

  Future<File?> highQualityImage(List<AssetEntity> media, int i) async =>
      media[i].file;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ValueListenableBuilder<bool>(
      valueListenable: noMedia,
      builder: (context, noImages, child) {
        if (noImages) {
          return Stack(
            children: [
              normalAppBar(withDoneButton: false, noImages: true),
              Align(
                child: Text(
                  widget.tabsTexts.noMediaFound,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          );
        } else {
          return buildGridView();
        }
      },
    );
  }

  Widget buildGridView() {
    return ValueListenableBuilder(
      valueListenable: isMediaReady,
      builder: (context, bool isImagesReadyValue, child) {
        if (isImagesReadyValue) {
          return ValueListenableBuilder<List<FutureBuilder<Uint8List?>>>(
            valueListenable: _mediaList,
            builder: (context, mediaList, child) {
              return ValueListenableBuilder(
                valueListenable: lastPage,
                builder: (context, int lastPageValue, child) =>
                    ValueListenableBuilder(
                  valueListenable: currentPage,
                  builder: (context, int currentPageValue, child) {
                    if (!widget.showImagePreview) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          normalAppBar(),
                          Flexible(
                            child: normalGridView(
                              mediaList,
                              currentPageValue,
                              lastPageValue,
                            ),
                          ),
                        ],
                      );
                    } else {
                      return instagramGridView(
                        mediaList,
                        currentPageValue,
                        lastPageValue,
                      );
                    }
                  },
                ),
              );
            },
          );
        } else {
          return loadingWidget();
        }
      },
    );
  }

  Widget loadingWidget() {
    return SingleChildScrollView(
      child: Column(
        children: [
          appBar(),
          Shimmer.fromColors(
            baseColor: widget.appTheme.shimmerBaseColor,
            highlightColor: widget.appTheme.shimmerHighlightColor,
            child: Column(
              children: [
                if (widget.showImagePreview) ...[
                  Container(
                    color: appTheme.shimmerHighlightColor,
                    height: 360,
                    width: double.infinity,
                  ),
                  const SizedBox(height: 1),
                ],
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: widget.gridDelegate.crossAxisSpacing,
                  ),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    primary: false,
                    gridDelegate: widget.gridDelegate,
                    itemBuilder: (context, index) {
                      return Container(
                        color: appTheme.shimmerHighlightColor,
                        width: double.infinity,
                      );
                    },
                    itemCount: 40,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  AppBar appBar() {
    return AppBar(
      backgroundColor: appTheme.surfaceColor,
      elevation: 0,
      leading: exitButton(),
      centerTitle: false,
      title: Text(
        widget.pickAvatar
            ? widget.tabsTexts.newAvatarImageText
            : widget.tabsTexts.newPostText,
      ),
    );
  }

  Widget normalAppBar({bool withDoneButton = true, bool noImages = false}) {
    final width = MediaQuery.sizeOf(context).width;

    return Container(
      color: widget.appTheme.surfaceColor,
      height: 56,
      width: width,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              exitButton(),
              const SizedBox(width: 24),
              Text(
                widget.pickAvatar
                    ? widget.tabsTexts.newAvatarImageText
                    : widget.tabsTexts.newPostText,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
          if (withDoneButton) ...[
            doneButton(),
          ],
        ],
      ),
    );
  }

  IconButton exitButton() {
    return IconButton(
      icon: Icon(Icons.clear_rounded, color: appTheme.onSurfaceColor, size: 30),
      onPressed: () {
        if (widget.onBackButtonTap == null) {
          Navigator.of(context).maybePop();
        } else {
          widget.onBackButtonTap!.call();
        }
        resetAll();
      },
    );
  }

  Widget doneButton() {
    return ValueListenableBuilder(
      valueListenable: indexOfSelectedMedia,
      builder: (context, List<int> indexOfSelectedImagesValue, child) =>
          ValueListenableBuilder<int>(
        valueListenable: indexOfLatestMedia,
        builder: (context, indexOfLatestImage, snapshot) {
          return IconButton(
            icon: Icon(
              Icons.arrow_forward_rounded,
              color: widget.appTheme.primaryColor,
              size: 30,
            ),
            onPressed: () async {
              final aspect = expandMedia.value ? 4 / 5 : 1.0;
              if (widget.multiSelectionMode.value && widget.multiSelection) {
                if (areaOfCropsKeys.value.length !=
                    widget.multiSelectedMedia.value.length) {
                  scaleOfCropsKeys.value.add(cropKey.currentState?.scale);
                  areaOfCropsKeys.value.add(cropKey.currentState?.area);
                } else {
                  if (indexOfLatestImage != -1) {
                    scaleOfCropsKeys.value[indexOfLatestImage] =
                        cropKey.currentState?.scale;
                    areaOfCropsKeys.value[indexOfLatestImage] =
                        cropKey.currentState?.area;
                  }
                }

                final selectedBytes = <SelectedByte>[];
                for (var i = 0;
                    i < widget.multiSelectedMedia.value.length;
                    i++) {
                  final currentImage = widget.multiSelectedMedia.value[i];
                  final isThatVideo = currentImage.isVideo;
                  final croppedImage = !isThatVideo && widget.cropImage
                      ? await cropImage(currentImage, indexOfCropImage: i)
                      : null;
                  final image = croppedImage ?? currentImage;
                  final byte = await image.readAsBytes();
                  final img = SelectedByte(
                    isThatImage: !isThatVideo,
                    selectedFile: image,
                    selectedByte: byte,
                  );
                  selectedBytes.add(img);
                }
                if (selectedBytes.isNotEmpty) {
                  final details = SelectedImagesDetails(
                    selectedFiles: selectedBytes,
                    multiSelectionMode: true,
                    aspectRatio: aspect,
                  );
                  if (!mounted) return;

                  void pop() => Navigator.of(context).maybePop(details);
                  if (widget.callbackFunction != null) {
                    await widget.callbackFunction!.call(details);
                  } else {
                    pop.call();
                  }
                }
              } else {
                final image = selectedMedia.value;
                if (image == null) return;
                final isThatVideo = image.isVideo;
                final croppedImage = !isThatVideo && widget.cropImage
                    ? await cropImage(image)
                    : null;
                final img = croppedImage ?? image;
                final byte = await img.readAsBytes();

                final selectedByte = SelectedByte(
                  isThatImage: !isThatVideo,
                  selectedFile: img,
                  selectedByte: byte,
                );
                final details = SelectedImagesDetails(
                  multiSelectionMode: false,
                  aspectRatio: aspect,
                  selectedFiles: [selectedByte],
                );
                if (!mounted) return;

                void pop() => Navigator.of(context).maybePop(details);
                if (widget.callbackFunction != null) {
                  await widget.callbackFunction!(details);
                } else {
                  pop.call();
                }
              }
            },
          );
        },
      ),
    );
  }

  Widget normalGridView(
    List<FutureBuilder<Uint8List?>> mediaListValue,
    int currentPageValue,
    int lastPageValue,
  ) {
    return NotificationListener(
      onNotification: (ScrollNotification notification) {
        _handleScrollEvent(
          notification,
          currentPageValue: currentPageValue,
          lastPageValue: lastPageValue,
        );
        return true;
      },
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: widget.gridDelegate.crossAxisSpacing,
        ),
        child: GridView.builder(
          gridDelegate: widget.gridDelegate,
          itemBuilder: (context, index) {
            return buildImage(mediaListValue, index);
          },
          itemCount: mediaListValue.length,
        ),
      ),
    );
  }

  ValueListenableBuilder<File?> buildImage(
    List<FutureBuilder<Uint8List?>> mediaListValue,
    int index,
  ) {
    return ValueListenableBuilder(
      valueListenable: selectedMedia,
      builder: (context, File? selectedImageValue, child) {
        return ValueListenableBuilder(
          valueListenable: allMedia,
          builder: (context, List<File?> allImagesValue, child) {
            return ValueListenableBuilder(
              valueListenable: widget.multiSelectedMedia,
              builder: (context, List<File> selectedImagesValue, child) {
                final mediaList = mediaListValue[index];
                final image = allImagesValue[index];
                if (image != null) {
                  final imageSelected = selectedImagesValue.contains(image);
                  final multiImages = selectedImagesValue;

                  return Stack(
                    children: [
                      gestureDetector(image, index, mediaList),
                      if (selectedImageValue == image)
                        gestureDetector(image, index, blurContainer()),
                      MultiSelectionMode(
                        appTheme: widget.appTheme,
                        image: image,
                        multiSelectionMode: widget.multiSelectionMode,
                        imageSelected: imageSelected,
                        multiSelectedImage: multiImages,
                      ),
                    ],
                  );
                } else {
                  return const SizedBox.shrink();
                }
              },
            );
          },
        );
      },
    );
  }

  Container blurContainer() {
    return Container(
      width: double.infinity,
      color: widget.appTheme.outlineColor.withValues(alpha: 0.4),
      height: double.maxFinite,
    );
  }

  Widget gestureDetector(File image, int index, Widget childWidget) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        widget.multiSelectionMode,
        widget.multiSelectedMedia,
        indexOfLatestMedia,
      ]),
      builder: (context, child) {
        return GestureDetector(
          key: ValueKey(index),
          onTap: () =>
              onTapImage(image, widget.multiSelectedMedia.value, index),
          onLongPress: () {
            if (widget.multiSelection) {
              widget.multiSelectionMode.value = true;
            }
          },
          onLongPressUp: () {
            if (widget.multiSelectionMode.value) {
              selectionImageCheck(
                image,
                widget.multiSelectedMedia.value,
                index,
                enableCopy: true,
              );
              expandImageView.value = false;
              moveAwayHeight.value = 0;

              enableVerticalTapping.value = false;
              noPaddingForGridView.value = true;
            } else {
              onTapImage(image, widget.multiSelectedMedia.value, index);
            }
          },
          child: childWidget,
        );
      },
    );
  }

  void onTapImage(File image, List<File> selectedImagesValue, int index) {
    // setState(() {
    if (widget.multiSelectionMode.value) {
      final close = selectionImageCheck(image, selectedImagesValue, index);
      if (close) return;
    }
    selectedMedia.value = image;
    expandImageView.value = false;
    moveAwayHeight.value = 0;
    enableVerticalTapping.value = false;
    noPaddingForGridView.value = true;
    // });
  }

  bool selectionImageCheck(
    File image,
    List<File> multiSelectionValue,
    int index, {
    bool enableCopy = false,
  }) {
    selectedMedia.value = image;
    if (multiSelectionValue.contains(image) && selectedMedia.value == image) {
      final indexOfImage =
          multiSelectionValue.indexWhere((element) => element == image);
      multiSelectionValue.removeAt(indexOfImage);
      if (multiSelectionValue.isNotEmpty &&
          indexOfImage < scaleOfCropsKeys.value.length) {
        indexOfSelectedMedia.value.remove(index);

        scaleOfCropsKeys.value.removeAt(indexOfImage);
        areaOfCropsKeys.value.removeAt(indexOfImage);
        indexOfLatestMedia.value = -1;
      }

      return true;
    } else {
      if (multiSelectionValue.length < widget.maximumSelection) {
        if (!multiSelectionValue.contains(image)) {
          multiSelectionValue.add(image);
          if (multiSelectionValue.length > 1) {
            scaleOfCropsKeys.value.add(cropKey.currentState?.scale);
            areaOfCropsKeys.value.add(cropKey.currentState?.area);
            indexOfSelectedMedia.value.add(index);
          }
        } else if (areaOfCropsKeys.value.length != multiSelectionValue.length) {
          scaleOfCropsKeys.value.add(cropKey.currentState?.scale);
          areaOfCropsKeys.value.add(cropKey.currentState?.area);
        }
        if (widget.showImagePreview && multiSelectionValue.contains(image)) {
          final index =
              multiSelectionValue.indexWhere((element) => element == image);
          if (indexOfLatestMedia.value != -1) {
            scaleOfCropsKeys.value[indexOfLatestMedia.value] =
                cropKey.currentState?.scale;
            areaOfCropsKeys.value[indexOfLatestMedia.value] =
                cropKey.currentState?.area;
          }
          indexOfLatestMedia.value = index;
        }

        if (enableCopy) selectedMedia.value = image;
      }
      return false;
    }
  }

  Future<File?> cropImage(File imageFile, {int? indexOfCropImage}) async {
    await InstaAssetsCrop.requestPermissions();
    double? scale;
    Rect? area;
    if (indexOfCropImage == null) {
      scale = cropKey.currentState?.scale;
      area = cropKey.currentState?.area;
    } else {
      scale = scaleOfCropsKeys.value[indexOfCropImage];
      area = areaOfCropsKeys.value[indexOfCropImage];
    }

    if (area == null || scale == null) return null;

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

  void clearMultiImages() {
    widget.multiSelectedMedia.value = [];
    widget.clearMultiImages();
    indexOfSelectedMedia.value.clear();
    scaleOfCropsKeys.value.clear();
    areaOfCropsKeys.value.clear();
  }

  Widget instagramGridView(
    List<FutureBuilder<Uint8List?>> mediaList,
    int currentPageValue,
    int lastPageValue,
  ) {
    return ValueListenableBuilder<double>(
      valueListenable: expandHeight,
      builder: (context, expandedHeightValue, child) {
        return ValueListenableBuilder<double>(
          valueListenable: moveAwayHeight,
          builder: (context, moveAwayHeightValue, child) =>
              ValueListenableBuilder<double>(
            valueListenable: scrollPixels,
            builder: (context, scrollPixels, snapshot) {
              return ValueListenableBuilder<bool>(
                valueListenable: noPaddingForGridView,
                builder: (context, noPaddingForGridView, snapshot) {
                  return ValueListenableBuilder<bool>(
                    valueListenable: expandImageView,
                    builder: (context, expandImageValue, child) {
                      final a = expandedHeightValue - 360;
                      final expandHeightV = a < 0.0 ? a : 0.0;
                      final moveAwayHeightV = moveAwayHeightValue < 360
                          ? moveAwayHeightValue * -1.0
                          : -360.0;
                      final topPosition =
                          expandImageValue ? expandHeightV : moveAwayHeightV;
                      enableVerticalTapping.value = !(topPosition == 0);
                      var padding = 2.0;
                      if (scrollPixels < 416) {
                        final pixels = 416 - scrollPixels;
                        padding = pixels >= 58 ? pixels + 2 : 58;
                      } else if (expandImageValue) {
                        padding = 58;
                      } else if (noPaddingForGridView) {
                        padding = 58;
                      } else {
                        padding = topPosition + 418;
                      }
                      final duration = noDuration.value ? 0 : 250;

                      return Stack(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(top: padding),
                            child: NotificationListener<ScrollNotification>(
                              onNotification: (notification) {
                                expandImageView.value = false;
                                moveAwayHeight.value =
                                    scrollController.position.pixels;
                                this.scrollPixels.value =
                                    scrollController.position.pixels;
                                isScrolling.value = true;
                                noPaddingForGridView = false;
                                noDuration.value = false;
                                if (notification is ScrollEndNotification) {
                                  expandHeight.value =
                                      expandedHeightValue > 240 ? 360 : 0;
                                  isScrolling.value = false;
                                }

                                _handleScrollEvent(
                                  notification,
                                  currentPageValue: currentPageValue,
                                  lastPageValue: lastPageValue,
                                );
                                return true;
                              },
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal:
                                      widget.gridDelegate.crossAxisSpacing,
                                ),
                                child: GridView.builder(
                                  gridDelegate: widget.gridDelegate,
                                  controller: scrollController,
                                  itemBuilder: (context, index) {
                                    return buildImage(mediaList, index);
                                  },
                                  itemCount: mediaList.length,
                                ),
                              ),
                            ),
                          ),
                          AnimatedPositioned(
                            top: topPosition,
                            duration: Duration(milliseconds: duration),
                            child: Column(
                              children: [
                                normalAppBar(),
                                CropImageView(
                                  cropKey: cropKey,
                                  indexOfSelectedImages: indexOfSelectedMedia,
                                  withMultiSelection: widget.multiSelection,
                                  selectedImage: selectedMedia,
                                  appTheme: widget.appTheme,
                                  multiSelectionMode: widget.multiSelectionMode,
                                  enableVerticalTapping: enableVerticalTapping,
                                  expandHeight: expandHeight,
                                  expandImage: expandMedia,
                                  expandImageView: expandImageView,
                                  noDuration: noDuration,
                                  clearMultiImages: clearMultiImages,
                                  topPosition: topPosition,
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => widget.wantKeepAlive;
}

class VideoThumbnailFooter extends StatelessWidget {
  const VideoThumbnailFooter({required this.asset, super.key});

  final AssetEntity asset;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.slow_motion_video_rounded,
          color: Colors.white,
          size: 18,
        ),
        const SizedBox(width: 4),
        Text(
          parseDuration(asset.videoDuration.inSeconds),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 14,
            overflow: TextOverflow.visible,
          ),
        ),
      ],
    );
  }

  String parseDuration(int seconds) {
    if (seconds < 600) {
      return '${Duration(seconds: seconds)}'.substring(3, 7);
    } else if (seconds > 600 && seconds < 3599) {
      return '${Duration(seconds: seconds)}'.substring(2, 7);
    } else {
      return '${Duration(seconds: seconds)}'.substring(1, 7);
    }
  }
}
