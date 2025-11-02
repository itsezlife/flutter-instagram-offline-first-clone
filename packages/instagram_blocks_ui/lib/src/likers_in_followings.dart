import 'package:app_ui/app_ui.dart';
import 'package:avatar_stack/avatar_stack.dart';
import 'package:avatar_stack/positions.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:user_repository/user_repository.dart';

class LikersInFollowings extends StatelessWidget {
  const LikersInFollowings({
    required this.likersInFollowings,
    super.key,
  });

  final List<User> likersInFollowings;

  double get _avatarStackWidth {
    if (likersInFollowings.length case 1) return 28;
    if (likersInFollowings.length case 2) return 44;
    return 60;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 28,
      width: _avatarStackWidth,
      child: WidgetStack(
        positions: RestrictedPositions(laying: StackLaying.first),
        stackedWidgets: [
          for (var i = 0; i < likersInFollowings.length; i++)
            if (likersInFollowings[i].avatarUrl == null)
              CircleAvatar(
                backgroundColor: context.reversedAdaptiveColor,
                child: ConstrainedBox(
                  constraints: const BoxConstraints.expand(),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xxs),
                    child: CircleAvatar(
                      backgroundColor: AppColors.white,
                      foregroundImage: ResizeImage(
                        Assets.images.profilePhoto.provider(),
                        height: 72,
                      ),
                    ),
                  ),
                ),
              )
            else
              CachedNetworkImage(
                imageUrl: likersInFollowings[i].avatarUrl!,
                cacheKey: likersInFollowings[i].avatarUrl,
                errorWidget: (context, url, error) {
                  return CircleAvatar(
                    backgroundColor: context.reversedAdaptiveColor,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints.expand(),
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.xxs),
                        child: CircleAvatar(
                          backgroundColor: AppColors.white,
                          foregroundImage: ResizeImage(
                            Assets.images.profilePhoto.provider(),
                            height: 72,
                          ),
                        ),
                      ),
                    ),
                  );
                },
                imageBuilder: (context, imageProvider) {
                  return CircleAvatar(
                    backgroundColor: context.reversedAdaptiveColor,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints.expand(),
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.xxs),
                        child: CircleAvatar(
                          backgroundImage: ResizeImage(
                            imageProvider,
                            height: 72,
                          ),
                          backgroundColor: context.theme.colorScheme.surface,
                        ),
                      ),
                    ),
                  );
                },
              ),
        ],
        buildInfoWidget: (_, _) => const SizedBox.shrink(),
      ),
    );
  }
}
