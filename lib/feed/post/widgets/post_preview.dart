import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/feed/feed.dart';
import 'package:flutter_instagram_offline_first_clone/feed/post/post.dart';
import 'package:flutter_instagram_offline_first_clone/l10n/l10n.dart';
import 'package:shared/shared.dart';
import 'package:sliver_tools/sliver_tools.dart';

class PostPreviewPage extends StatelessWidget {
  const PostPreviewPage({
    required this.id,
    super.key,
  });

  final String id;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: const PostPreviewAppBar(),
      body: PostPreviewDetails(id: id),
    );
  }
}

class PostPreviewAppBar extends StatelessWidget implements PreferredSizeWidget {
  const PostPreviewAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const AppLogo(),
      centerTitle: false,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class PostPreviewNotFound extends StatelessWidget {
  const PostPreviewNotFound({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Text(
          context.l10n.noPostFoundText,
          style: context.headlineSmall,
        ),
      ),
    );
  }
}

class PostPreviewDetails extends StatefulWidget {
  const PostPreviewDetails({required this.id, super.key});

  final String id;

  @override
  State<PostPreviewDetails> createState() => _PostPreviewDetailsState();
}

class _PostPreviewDetailsState extends State<PostPreviewDetails> {
  PostBlock? _block;
  bool _hasData = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    setState(() => _isLoading = true);
    context
        .read<FeedBloc>()
        .getPostBy(widget.id)
        .then(
          (value) => setState(() {
            _block = value;
            _hasData = value != null;
            _isLoading = false;
          }),
        );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator.adaptive(
      onRefresh: () async => context
          .read<FeedBloc>()
          .getPostBy(widget.id)
          .then((value) => setState(() => _block = value)),
      child: CustomScrollView(
        slivers: [
          SliverAnimatedSwitcher(
            duration: 150.ms,
            child: !_isLoading && _hasData
                ? SliverToBoxAdapter(
                    child: PostView(
                      key: ValueKey(_block!.id),
                      block: _block!,
                      withCustomVideoPlayer: false,
                      withInViewNotifier: false,
                    ),
                  )
                : _isLoading
                ? const PostPreviewLoading()
                : const PostPreviewNotFound(),
          ),
        ],
      ),
    );
  }
}

class PostPreviewLoading extends StatelessWidget {
  const PostPreviewLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return const SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: CircularProgressIndicator.adaptive(),
      ),
    );
  }
}
