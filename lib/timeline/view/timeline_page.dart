import 'dart:math';

import 'package:app_ui/app_ui.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/feed/post/post.dart';
import 'package:flutter_instagram_offline_first_clone/feed/post/video/video.dart';
import 'package:flutter_instagram_offline_first_clone/l10n/l10n.dart';
import 'package:flutter_instagram_offline_first_clone/search/view/search_page.dart';
import 'package:flutter_instagram_offline_first_clone/timeline/timeline.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:instagram_blocks_ui/instagram_blocks_ui.dart' hide VideoPlayer;
import 'package:inview_notifier_list/inview_notifier_list.dart';
import 'package:posts_repository/posts_repository.dart';
import 'package:shared/shared.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sliver_tools/sliver_tools.dart';

class TimelinePage extends StatelessWidget {
  const TimelinePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TimelineBloc(
        postsRepository: context.read<PostsRepository>(),
      )..add(const TimelinePageRequested()),
      child: const TimelineView(),
    );
  }
}

class TimelineView extends StatefulWidget {
  const TimelineView({super.key});

  @override
  State<TimelineView> createState() => _TimelineViewState();
}

class _TimelineViewState extends State<TimelineView>
    with SingleTickerProviderStateMixin {
  late final Animation<double> _animation = CurvedAnimation(
    curve: Curves.easeOutQuad,
    parent: _controller,
  );
  late final AnimationController _controller = AnimationController(vsync: this);
  final _isNextPageLoading = ValueNotifier(false);

  @override
  void dispose() {
    _isNextPageLoading.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasMore = context.select(
      (TimelineBloc bloc) => bloc.state.timeline.hasMore,
    );

    return AppScaffold(
      releaseFocus: true,
      body: RefreshIndicator.adaptive(
        onRefresh: () async =>
            context.read<TimelineBloc>().add(const TimelineRefreshRequested()),
        child: InViewNotifierCustomScrollView(
          onListEndReached: () async {
            if (!hasMore) return;
            Future<void> onEndReached() async =>
                context.read<TimelineBloc>().add(const TimelinePageRequested());

            if (_isNextPageLoading.value) return;

            _controller
              ..duration = Duration.zero
              // ignore: unawaited_futures
              ..forward();

            _isNextPageLoading.value = true;

            await onEndReached().whenComplete(() {
              if (mounted) {
                _controller
                  ..duration = const Duration(milliseconds: 300)
                  ..reverse();

                _isNextPageLoading.value = false;
              }
            });
          },
          initialInViewIds: const ['2', '5'],
          isInViewPortCondition: (deltaTop, deltaBottom, vpHeight) =>
              deltaTop < (0.5 * vpHeight) + 220.0 &&
              deltaBottom > (0.5 * vpHeight) - 220.0,
          slivers: [
            const SliverAppBar(
              title: SearchInputField(
                active: true,
                readOnly: true,
              ),
              floating: true,
              toolbarHeight: 64,
            ),
            BlocBuilder<TimelineBloc, TimelineState>(
              buildWhen: (previous, current) {
                return current.status.isPopulated &&
                    !const ListEquality<InstaBlock>().equals(
                      previous.timeline.blocks,
                      current.timeline.blocks,
                    );
              },
              builder: (context, state) {
                if (state.status.isFailure) return const TimelineError();
                return SliverAnimatedSwitcher(
                  duration: 150.ms,
                  child: state.status.isPopulated
                      ? TimelineGridView(
                          blocks: state.timeline.blocks.cast<PostBlock>(),
                        )
                      : const TimelineLoading(),
                );
              },
            ),
            SliverPadding(
              padding: EdgeInsets.only(
                top:
                    16 +
                    (context.isMobile ? MediaQuery.paddingOf(context).top : 0),
              ),
              sliver: SliverToBoxAdapter(
                child: SizeTransition(
                  axisAlignment: 1,
                  sizeFactor: _animation,
                  child: Center(
                    child: Container(
                      alignment: Alignment.center,
                      height: 38,
                      width: 38,
                      child: const SizedBox(
                        height: 26,
                        width: 26,
                        child: CircularProgressIndicator.adaptive(
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TimelineGridView extends StatelessWidget {
  const TimelineGridView({
    required this.blocks,
    super.key,
  });

  final List<PostBlock> blocks;

  @override
  Widget build(BuildContext context) {
    return SliverGrid.builder(
      gridDelegate: SliverQuiltedGridDelegate(
        crossAxisCount: 3,
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
        repeatPattern: QuiltedGridRepeatPattern.inverted,
        pattern: [
          const QuiltedGridTile(1, 1),
          const QuiltedGridTile(1, 1),
          const QuiltedGridTile(2, 1),
          const QuiltedGridTile(1, 1),
          const QuiltedGridTile(1, 1),
        ],
      ),
      itemCount: blocks.length,
      itemBuilder: (context, index) {
        final block = blocks[index];
        final multiMedia = block.media.length > 1;

        return PostPopup(
          key: ValueKey(block.id),
          block: block,
          index: index,
          showComments: false,
          builder: (_) => PostSmall(
            pinned: false,
            isReel: block.isReel,
            multiMedia: multiMedia,
            mediaUrl: block.firstMediaUrl!,
            imageThumbnailBuilder: (_, url) => block.isReel
                ? VideoPlayerInViewNotifierWidget(
                    type: VideoPlayerType.timeline,
                    id: '$index',
                    checkIsInView: true,
                    builder: (context, shouldPlay, child) {
                      return InlineVideo(
                        videoSettings: VideoSettings.build(
                          videoUrl: block.firstMedia!.url,
                          shouldPlay: shouldPlay,
                          withSound: false,
                          shouldExpand: true,
                          blurHash: block.firstMedia!.blurHash,
                          withSoundButton: false,
                          withPlayerController: false,
                          videoPlayerOptions: VideoPlayerOptions(
                            mixWithOthers: true,
                          ),
                          initDelay: 250,
                        ),
                      );
                    },
                  )
                : TimelinePostImage(post: block),
          ),
        );
      },
    );
  }
}

class TimelinePostImage extends StatelessWidget {
  const TimelinePostImage({required this.post, super.key});

  final PostBlock post;

  @override
  Widget build(BuildContext context) {
    /// AppSpacing.xxs is the padding of the image.
    final screenWidth = (context.screenWidth - AppSpacing.xxs) / 3;
    final pixelRatio = context.devicePixelRatio;

    final height = min((screenWidth * pixelRatio) ~/ 1, 1920);

    return BlurHashImageThumbnail(
      id: post.id,
      height: height,
      url: post.firstMediaUrl!,
      blurHash: post.firstMedia?.blurHash,
    );
  }
}

class TimelineLoading extends StatelessWidget {
  const TimelineLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      child: Shimmer.fromColors(
        baseColor: const Color(0xff2d2f2f),
        highlightColor: const Color(0xff13151b),
        child: GridView.builder(
          gridDelegate: SliverQuiltedGridDelegate(
            crossAxisCount: 3,
            mainAxisSpacing: 2,
            crossAxisSpacing: 2,
            repeatPattern: QuiltedGridRepeatPattern.inverted,
            pattern: [
              const QuiltedGridTile(1, 1),
              const QuiltedGridTile(1, 1),
              const QuiltedGridTile(2, 1),
              const QuiltedGridTile(1, 1),
              const QuiltedGridTile(1, 1),
            ],
          ),
          itemCount: 20,
          itemBuilder: (context, index) =>
              const ColoredBox(color: AppColors.dark),
        ),
      ),
    );
  }
}

class TimelineError extends StatelessWidget {
  const TimelineError({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            context.l10n.somethingWentWrongText,
            style: context.headlineSmall,
          ),
          gapH8,
          FittedBox(
            child: Tappable.faded(
              onTap: () => context.read<TimelineBloc>().add(
                const TimelinePageRequested(),
              ),
              throttle: true,
              throttleDuration: 880.ms,
              borderRadius: BorderRadius.circular(22),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(color: context.adaptiveColor),
                ),
                child: Align(
                  child: Row(
                    children: <Widget>[
                      const Icon(Icons.refresh),
                      gapW12,
                      Text(
                        context.l10n.refreshText,
                        style: context.labelLarge,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
