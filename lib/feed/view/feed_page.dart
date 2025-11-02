import 'package:app_ui/app_ui.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/feed/feed.dart';
import 'package:flutter_instagram_offline_first_clone/feed/post/post.dart';
import 'package:flutter_instagram_offline_first_clone/l10n/l10n.dart';
import 'package:flutter_instagram_offline_first_clone/stories/stories.dart';
import 'package:flutter_instagram_offline_first_clone/user_profile/user_profile.dart';
import 'package:inview_notifier_list/inview_notifier_list.dart';
import 'package:shared/shared.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:stories_repository/stories_repository.dart';
import 'package:user_repository/user_repository.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key, this.initialPage = 1});

  final int initialPage;

  @override
  State<FeedPage> createState() => FeedPageState();
}

class FeedPageState extends State<FeedPage> with RouteAware {
  late PageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PageController(initialPage: widget.initialPage);
    context.read<UserProfileBloc>().add(
      const UserProfileFetchFollowingsRequested(),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => StoriesBloc(
        storiesRepository: context.read<StoriesRepository>(),
        userRepository: context.read<UserRepository>(),
      )..add(const StoriesFetchUserFollowingsStories()),
      child: const FeedView(),
    );
  }
}

/// {@template feed_view}
/// The main FeedView widget that builds the UI for the feed screen.
/// {@endtemplate}
class FeedView extends StatefulWidget {
  const FeedView({super.key});

  @override
  State<FeedView> createState() => _FeedViewState();
}

class _FeedViewState extends State<FeedView> {
  late ScrollController _nestedScrollController;

  @override
  void initState() {
    super.initState();
    context.read<FeedBloc>().add(const FeedPageRequested(page: 0));

    _nestedScrollController = ScrollController();
    FeedPageController().init(
      nestedScrollController: _nestedScrollController,
      context: context,
    );
  }

  @override
  void dispose() {
    _nestedScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      releaseFocus: true,
      body: NestedScrollView(
        floatHeaderSlivers: true,
        controller: _nestedScrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverOverlapAbsorber(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
              sliver: FeedAppBar(innerBoxIsScrolled: innerBoxIsScrolled),
            ),
          ];
        },
        body: const FeedBody(),
      ),
    );
  }
}

class FeedBody extends StatelessWidget {
  const FeedBody({super.key});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator.adaptive(
      onRefresh: () async {
        Future<void> refresh() async {
          context.read<FeedBloc>().add(const FeedRefreshRequested());
          context.read<StoriesBloc>().add(
            const StoriesFetchUserFollowingsStories(),
          );
        }

        await Future<void>.delayed(1.seconds);
        await refresh();
        FeedPageController().markAnimationAsUnseen();
      },
      child: InViewNotifierCustomScrollView(
        initialInViewIds: const ['0'],
        isInViewPortCondition: (deltaTop, deltaBottom, vpHeight) {
          return deltaTop < (0.5 * vpHeight) + 80.0 &&
              deltaBottom > (0.5 * vpHeight) - 80.0;
        },
        slivers: [
          SliverOverlapInjector(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
          ),
          const StoriesCarousel(),
          const AppSliverDivider(),
          BlocBuilder<FeedBloc, FeedState>(
            buildWhen: (previous, current) {
              // Consider building when status is loading and the page is 0
              // or when the status is populated and the blocks are different
              return current.status.isLoading &&
                      current.feed.feedPage.page == 0 ||
                  current.status.isPopulated &&
                      !const ListEquality<InstaBlock>().equals(
                        previous.feed.feedPage.blocks,
                        current.feed.feedPage.blocks,
                      );
            },
            builder: (context, state) {
              final feedPage = state.feed.feedPage;
              final isLoading = state.status.isLoading;

              return SliverAnimatedSwitcher(
                duration: 150.ms,
                child: !isLoading
                    ? FeedPageListView(blocks: feedPage.blocks)
                    : const SliverToBoxAdapter(
                        child: Column(
                          children: [
                            FeedLoadingBlock(),
                            Gap.v(AppSpacing.md),
                            FeedLoadingBlock(),
                          ],
                        ),
                      ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class FeedPageListView extends StatefulWidget {
  const FeedPageListView({required this.blocks, super.key});

  final List<InstaBlock> blocks;

  @override
  State<FeedPageListView> createState() => _FeedPageListViewState();
}

class _FeedPageListViewState extends State<FeedPageListView> {
  List<InstaBlock> get blocks => widget.blocks;

  final _listItemsMap = <String, int>{};

  @override
  void didUpdateWidget(covariant FeedPageListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.blocks != widget.blocks) {
      _updateBlocks();
    }
  }

  void _updateBlocks() {
    for (var i = 0; i < blocks.length; i++) {
      if (blocks[i].toJson()['id'] == null) continue;
      _listItemsMap[blocks[i].toJson()['id'] as String] = i;
    }
  }

  @override
  Widget build(BuildContext context) {
    final feedPageController = FeedPageController();

    return SliverList.builder(
      itemCount: blocks.length,
      findChildIndexCallback: (key) {
        final valueKey = key as ValueKey<String>;
        final val = _listItemsMap[valueKey.value];
        return val;
      },
      itemBuilder: (context, index) {
        final block = blocks[index];
        return _buildBlock(
          context: context,
          index: index,
          feedLength: blocks.length,
          block: block,
          feedPageController: feedPageController,
          // hasMorePosts: hasMorePosts,
          // isFailure: isFailure,
        );
      },
    );
  }

  Widget _buildBlock({
    required BuildContext context,
    required int index,
    required int feedLength,
    required InstaBlock block,
    required FeedPageController feedPageController,
    // required bool hasMorePosts,
    // required bool isFailure,
  }) {
    if (block is DividerHorizontalBlock) {
      return DividerBlock(feedPageController: feedPageController);
    }
    if (block is SectionHeaderBlock) {
      return switch (block.sectionType) {
        SectionHeaderBlockType.suggested => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              child: Text(
                context.l10n.suggestedForYouText,
                style: context.headlineSmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const AppDivider(),
            if (index + 1 == feedLength)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.md),
                child: FeedLoaderItem(
                  onPresented: () => context.read<FeedBloc>().add(
                    const FeedRecommendedPostsPageRequested(),
                  ),
                ),
              ),
          ],
        ),
      };
    }
    if (index + 1 == feedLength) {
      // if (isFailure) {
      // if (!hasMorePosts) return const SizedBox.shrink();
      // return NetworkError(
      // onRetry: () {
      // context.read<FeedBloc>().add(const FeedPageRequested());
      // },
      // );
      return Padding(
        padding: EdgeInsets.only(top: feedLength == 0 ? AppSpacing.md : 0),
        child: FeedLoaderItem(
          onPresented: () =>
              context.read<FeedBloc>().add(const FeedPageRequested()),
        ),
      );
    }
    if (block is PostBlock) {
      // return TestPageItem(post: block);
      return PostView(
        key: ValueKey(block.id),
        block: block,
        postIndex: index,
        withInViewNotifier: block.isReel,
      );
    }

    return Text('Unknown block type: ${block.type}');
  }
}
