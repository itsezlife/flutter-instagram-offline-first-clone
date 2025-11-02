import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/feed/post/post.dart';
import 'package:instagram_blocks_ui/instagram_blocks_ui.dart';
import 'package:shared/shared.dart';

class PostLikesCount extends StatelessWidget {
  const PostLikesCount({
    required this.block,
    required this.onUserTap,
    super.key,
  });

  final PostBlock block;
  final ValueSetter<String> onUserTap;

  @override
  Widget build(BuildContext context) {
    final likesCount = context.select((PostBloc bloc) => bloc.state.likes);
    final likersInFollowings = context.select(
      (PostBloc bloc) => bloc.state.likersInFollowings,
    );

    if (likesCount == 0) return const SizedBox.shrink();

    return Flexible(
      child: RepaintBoundary(
        child: LikesCount(
          key: ValueKey('likes-count-${block.id}'),
          count: likesCount,
          textBuilder: (count) {
            final user = likersInFollowings?.firstOrNull;
            final name = user?.displayUsername;
            final userId = user?.id;
            if (name == null || name.trim().isEmpty) {
              return null;
            }

            final onTap = userId == null ? null : () => onUserTap(userId);

            return BlockSettings().postTextDelegate.likedByText(
              count,
              name,
              onTap,
            );
          },
        ),
      ),
    );
  }
}
