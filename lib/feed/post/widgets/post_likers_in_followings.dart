import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/feed/post/post.dart';
import 'package:instagram_blocks_ui/instagram_blocks_ui.dart';

class PostLikersInFollowings extends StatelessWidget {
  const PostLikersInFollowings({super.key});

  @override
  Widget build(BuildContext context) {
    final likersInFollowings = context.select(
      (PostBloc bloc) => bloc.state.likersInFollowings,
    );

    if (likersInFollowings == null || likersInFollowings.isEmpty) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        LikersInFollowings(likersInFollowings: likersInFollowings),
        gapW4,
      ],
    );
  }
}
