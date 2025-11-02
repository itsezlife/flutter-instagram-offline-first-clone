import 'package:flutter/material.dart';
import 'package:gallery_media_picker/src/presentation/widgets/select_album_path/dropdown.dart';

class OverlayDropDown<T> extends StatelessWidget {
  const OverlayDropDown({
    required this.height,
    required this.close,
    required this.animationController,
    required this.builder,
    super.key,
  });

  final double height;
  final void Function(T? value) close;
  final AnimationController animationController;
  final DropdownWidgetBuilder<T> builder;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final screenHeight = size.height;
    final screenWidth = size.width;
    final space = screenHeight - height;

    return Padding(
      /// align overlay content behind the button
      padding: EdgeInsets.only(top: space),
      child: Align(
        alignment: Alignment.topLeft,
        child: Builder(
          builder: (ctx) => GestureDetector(
            onTap: () => close,

            /// close overlay
            child: AnimatedBuilder(
              animation: animationController,
              builder: (BuildContext context, child) {
                return Stack(
                  children: [
                    /// full content transparent container
                    GestureDetector(
                      onTap: () => close(null),

                      /// close overlay
                      child: Container(
                        color: Colors.transparent,
                        height: height * animationController.value,
                        width: screenWidth,
                      ),
                    ),

                    /// list of available albums
                    SizedBox(
                      height: height * animationController.value,
                      width: screenWidth * 0.5,
                      child: child,
                    ),
                  ],
                );
              },
              child: builder(ctx, close),
            ),
          ),
        ),
      ),
    );
  }
}
