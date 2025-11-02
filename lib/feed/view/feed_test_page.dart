import 'dart:math';

import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/feed/feed.dart';
import 'package:flutter_instagram_offline_first_clone/stories/stories.dart';
import 'package:inview_notifier_list/inview_notifier_list.dart';
import 'package:shared/shared.dart';
import 'package:stories_repository/stories_repository.dart';
import 'package:user_repository/user_repository.dart';

class FeedPageTestView extends StatelessWidget {
  const FeedPageTestView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => StoriesBloc(
        storiesRepository: context.read<StoriesRepository>(),
        userRepository: context.read<UserRepository>(),
      )..add(const StoriesFetchUserFollowingsStories()),
      child: const FeedPageTest(),
    );
  }
}

class FeedPageTest extends StatefulWidget {
  const FeedPageTest({super.key});

  @override
  State<FeedPageTest> createState() => _FeedPageTestState();
}

class _FeedPageTestState extends State<FeedPageTest> {
  final _list = ValueNotifier(
    [
      ...List.generate(50, (i) => '${i + Random().nextInt(1000)}'),
    ],
  );

  @override
  void dispose() {
    _list.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      floatingActionButton: FloatingActionButton.small(
        child: const Icon(Icons.add),
        onPressed: () =>
            _list.value = [..._list.value, Random().nextInt(100).toString()],
      ),
      body: NestedScrollView(
        floatHeaderSlivers: true,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverOverlapAbsorber(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
              sliver: FeedAppBar(innerBoxIsScrolled: innerBoxIsScrolled),
            ),
          ];
        },
        body: RefreshIndicator.adaptive(
          onRefresh: () async {
            final filledList = List.generate(
              20,
              (i) => '${i + Random().nextInt(1000)}',
            );
            _list.value = [..._list.value, ...filledList];
          },
          child: InViewNotifierCustomScrollView(
            initialInViewIds: const ['0'],
            onListEndReached: () {
              final filledList = List.generate(
                5,
                (i) => '${i + Random().nextInt(1000)}',
              );
              _list.value = [..._list.value, ...filledList];
            },
            isInViewPortCondition: (deltaTop, deltaBottom, vpHeight) {
              return deltaTop < (0.5 * vpHeight) + 80.0 &&
                  deltaBottom > (0.5 * vpHeight) - 80.0;
            },
            slivers: [
              const StoriesCarousel(),
              ValueListenableBuilder(
                valueListenable: _list,
                builder: (context, list, _) {
                  return FeedPostsListView(items: list);
                },
              ),
            ],
          ),
        ),
      ),
      // body: Column(
      //   children: [
      //     Flexible(
      //       child: ValueListenableBuilder(
      //         valueListenable: _list,
      //         builder: (context, list, _) {
      //           return FeedPostsListView(items: list);
      //         },
      //       ),
      //     ),
      //   ],
      // ),
    );
  }
}

class FeedPostsListView extends StatefulWidget {
  const FeedPostsListView({required this.items, super.key});

  final List<String> items;

  @override
  State<FeedPostsListView> createState() => _FeedPostsListViewState();
}

class _FeedPostsListViewState extends State<FeedPostsListView> {
  List<String> get items => widget.items;

  final _listItemsMap = <String, int>{};

  @override
  void didUpdateWidget(covariant FeedPostsListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items != widget.items) {
      _didChange();
    }
  }

  void _didChange() {
    for (var i = 0; i < items.length; i++) {
      if (_listItemsMap[items[i]] != null) continue;
      _listItemsMap[items[i]] = i;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SliverList.builder(
      itemBuilder: (context, index) {
        final item = items[index];
        return FeedItem(title: item);
      },
      findChildIndexCallback: (key) {
        final valueKey = key as ValueKey<String>;
        final val = _listItemsMap[valueKey.value];
        return val;
      },
      itemCount: items.length,
    );
  }
}

class FeedList extends StatefulWidget {
  const FeedList({required this.list, super.key});

  final List<String> list;

  @override
  State<FeedList> createState() => _FeedListState();
}

class _FeedListState extends State<FeedList> {
  final _listItemsMap = <ValueKey<String>, int>{};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _didChange();
  }

  void _didChange() {
    for (var i = 0; i < widget.list.length; i++) {
      if (_listItemsMap[ValueKey(widget.list[i])] != null) continue;
      _listItemsMap[ValueKey(widget.list[i])] = i;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SliverList.builder(
      itemCount: widget.list.length,
      findChildIndexCallback: (key) {
        final valueKey = key as ValueKey;
        final index = _listItemsMap[valueKey];
        if (index == -1) return null;
        return index;
      },
      itemBuilder: (context, index) {
        final item = widget.list[index];
        return FeedItem(
          key: ValueKey(item),
          title: item,
        );
      },
    );
  }
}

class FeedItem extends StatelessWidget {
  const FeedItem({required this.title, super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    logI('Rebuild item');
    return ListTile(
      title: Text(title),
    );
  }
}
