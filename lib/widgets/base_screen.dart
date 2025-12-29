import 'package:flutter/material.dart';
import 'custom_app_bar.dart';
import 'custom_drawer.dart';
import '../theme/app_colors.dart';

class BaseScreen extends StatelessWidget {
  final Widget body;
  final String title;
  final bool showBackButton;
  final List<Widget>? actions;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Color? backgroundColor;

  const BaseScreen({
    super.key,
    required this.body,
    this.title = 'SettingWala',
    this.showBackButton = false,
    this.actions,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
    final colors = context.colors;

    return Scaffold(
      key: scaffoldKey,
      resizeToAvoidBottomInset: true,
      appBar: CustomAppBar(
        scaffoldKey: scaffoldKey,
        title: title,
        showBackButton: showBackButton,
        actions: actions,
      ),
      endDrawer: const CustomDrawer(),
      body: body,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      backgroundColor: backgroundColor ?? colors.background,
    );
  }
}