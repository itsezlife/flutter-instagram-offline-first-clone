import 'package:flutter/material.dart';

class AppTheme {
  const AppTheme({
    this.primaryColor = Colors.deepPurple,
    this.primaryContainerColor = const Color.fromARGB(255, 77, 25, 166),
    this.surfaceColor = Colors.white,
    this.onSurfaceColor = Colors.black,
    this.shimmerBaseColor = Colors.grey,
    this.shimmerHighlightColor = Colors.white,
    this.errorColor = Colors.red,
    this.outlineColor = Colors.grey,
  });
  final Color primaryColor;
  final Color primaryContainerColor;
  final Color surfaceColor;
  final Color onSurfaceColor;
  final Color shimmerBaseColor;
  final Color shimmerHighlightColor;
  final Color errorColor;
  final Color outlineColor;
}
