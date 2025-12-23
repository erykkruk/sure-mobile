import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Centralized scaffold with theme integration
/// ALWAYS use AppScaffold instead of raw Scaffold
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    required this.body,
    this.appBar,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.drawer,
    this.endDrawer,
    this.backgroundColor,
    this.resizeToAvoidBottomInset = true,
    this.extendBody = false,
    this.extendBodyBehindAppBar = false,
    super.key,
  });

  /// Main content of the scaffold
  final Widget body;

  /// Optional app bar
  final PreferredSizeWidget? appBar;

  /// Optional floating action button
  final Widget? floatingActionButton;

  /// Optional bottom navigation bar
  final Widget? bottomNavigationBar;

  /// Optional drawer
  final Widget? drawer;

  /// Optional end drawer
  final Widget? endDrawer;

  /// Background color (defaults to theme background)
  final Color? backgroundColor;

  /// Whether to resize body when keyboard appears
  final bool resizeToAvoidBottomInset;

  /// Whether to extend body behind bottom navigation
  final bool extendBody;

  /// Whether to extend body behind app bar
  final bool extendBodyBehindAppBar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: body,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      drawer: drawer,
      endDrawer: endDrawer,
      backgroundColor: backgroundColor ?? AppColors.instance.backgroundPrimary,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      extendBody: extendBody,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
    );
  }
}
