import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:instagram_blocks_ui/instagram_blocks_ui.dart';
import 'package:instagram_blocks_ui/src/carousel_dot_indicator.dart';
import 'package:instagram_blocks_ui/src/comments_count.dart';
import 'package:instagram_blocks_ui/src/like_button.dart';
import 'package:instagram_blocks_ui/src/post_large/post_caption.dart';
import 'package:shared/shared.dart';

class PostFooter extends StatelessWidget {
  const PostFooter({
    required this.block,
    required this.indicatorValue,
    required this.mediasUrl,
    required this.isLiked,
    required this.likePost,
    required this.commentsCount,
    required this.onAvatarTap,
    required this.onUserTap,
    required this.onCommentsTap,
    required this.onPostShareTap,
    super.key,
    this.likersInFollowingsBuilder,
    this.likesCountBuilder,
  });

  final PostBlock block;
  final ValueNotifier<int> indicatorValue;
  final bool isLiked;
  final int commentsCount;
  final VoidCallback likePost;
  final List<String> mediasUrl;
  final ValueSetter<String?> onAvatarTap;
  final ValueSetter<String> onUserTap;
  final ValueSetter<bool> onCommentsTap;
  final OnPostShareTap onPostShareTap;
  final LikesCountBuilder? likesCountBuilder;
  final LikersInFollowingsBuilder? likersInFollowingsBuilder;

  @override
  Widget build(BuildContext context) {
    final isSponsored = block is PostSponsoredBlock;
    final author = block.author;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isSponsored)
          SponsoredPostAction(
            imageUrl: block.firstMedia?.url,
            onTap: () => onAvatarTap.call(author.avatarUrl),
          ),
        gapH8,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      LikeButton(
                        isLiked: isLiked,
                        onLikedTap: likePost,
                      ),
                      gapW16,
                      Tappable.scaled(
                        onTap: () => onCommentsTap(true),
                        child: Transform.flip(
                          flipX: true,
                          child: Assets.icons.chatCircle.svg(
                            height: AppSize.iconSize,
                            width: AppSize.iconSize,
                            colorFilter: ColorFilter.mode(
                              context.adaptiveColor,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                      gapW16,
                      Tappable.scaled(
                        onTap: () => onPostShareTap(block.id, block.author),
                        child: const Icon(
                          Icons.near_me_outlined,
                          size: AppSize.iconSize,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (mediasUrl.length > 1)
                ValueListenableBuilder(
                  valueListenable: indicatorValue,
                  builder: (context, index, child) {
                    return CarouselDotIndicator(
                      mediaCount: mediasUrl.length,
                      activeMediaIndex: index,
                    );
                  },
                ),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Tappable.scaled(
                    onTap: () {},
                    child: const Icon(
                      Icons.bookmark_outline_rounded,
                      size: AppSize.iconSize,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        gapH8,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (likersInFollowingsBuilder != null)
                    likersInFollowingsBuilder!.call(),
                  if (likesCountBuilder != null)
                    likesCountBuilder!.call(onUserTap),
                ],
              ),
              PostCaption(
                username: author.username,
                caption: block.caption,
                onUserProfileAvatarTap: () =>
                    onAvatarTap.call(author.avatarUrl),
              ),
              RepaintBoundary(
                child: CommentsCount(
                  count: commentsCount,
                  onTap: () => onCommentsTap.call(false),
                ),
              ),
              if (!isSponsored) TimeAgo(createdAt: block.createdAt),
              gapH8,
            ],
          ),
        ),
      ],
    );
  }
}

class SponsoredPostAction extends StatelessWidget {
  const SponsoredPostAction({
    required this.onTap,
    required this.imageUrl,
    super.key,
  });

  final String? imageUrl;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tappable.faded(
      backgroundColor: Colors.transparent,
      fadeStrength: FadeStrength.sm,
      onTap: onTap,
      child: AnimatedContainer(
        duration: 1700.ms,
        curve: Curves.easeInCubic,
        width: double.infinity,
        color: context.customReversedAdaptiveColor(
          dark: AppColors.deepBlue,
          light: AppColors.lightBlue,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              BlockSettings()
                  .postTextDelegate
                  .visitSponsoredInstagramProfileText,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: context.titleMedium?.copyWith(
                fontWeight: AppFontWeight.semiBold,
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: AppSize.iconSizeSmall,
            ),
          ],
        ),
      ),
    );
  }
}
