import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class FeedLoadingBlock extends StatelessWidget {
  const FeedLoadingBlock({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Shimmer.fromColors(
        baseColor: const Color(0xff2d2f2f),
        highlightColor: const Color(0xff13151b),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.dark,
                    shape: BoxShape.circle,
                  ),
                  child: SizedBox(height: 32, width: 32),
                ),
                const Gap.h(AppSpacing.md),
                Expanded(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.dark,
                      borderRadius: BorderRadius.circular(AppSpacing.xlg),
                    ),
                    child: const SizedBox(height: 16),
                  ),
                ),
              ],
            ),
            const Gap.v(AppSpacing.md),
            DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.dark,
                borderRadius: BorderRadius.circular(AppSpacing.xlg),
              ),
              child: SizedBox(
                height: context.screenHeight * .4,
                width: context.screenWidth,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
