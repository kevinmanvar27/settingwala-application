import 'package:flutter/material.dart';
import 'custom_app_bar.dart';
import 'custom_drawer.dart';
import '../theme/app_colors.dart';
import '../providers/chat_icon_provider.dart';

class BaseScreen extends StatefulWidget {
  final Widget body;
  final String title;
  final bool showBackButton;
  final List<Widget>? actions;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Color? backgroundColor;
  final bool maintainFocus;
  final bool? showChatIcon; // Nullable - when null, uses ChatIconProvider

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
    this.maintainFocus = false,
    this.showChatIcon, // Nullable - defaults to provider value when null
  });

  @override
  State<BaseScreen> createState() => _BaseScreenState();
}

class _BaseScreenState extends State<BaseScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final chatNotifier = ChatIconProvider.maybeOf(context);

    // Use ListenableBuilder to rebuild AppBar when chat icon visibility changes
    return ListenableBuilder(
      listenable: chatNotifier ?? ChangeNotifier(),
      builder: (context, child) {
        return Scaffold(
          key: _scaffoldKey,
          resizeToAvoidBottomInset: true,
          primary: true,
          appBar: CustomAppBar(
            scaffoldKey: _scaffoldKey,
            title: widget.title,
            showBackButton: widget.showBackButton,
            actions: widget.actions,
            showChatIcon: widget.showChatIcon, // Pass through nullable - CustomAppBar uses provider when null
          ),
          endDrawer: const CustomDrawer(),
          body: SafeArea(
            bottom: false,
            child: widget.body,
          ),
          bottomNavigationBar: widget.bottomNavigationBar,
          floatingActionButton: widget.floatingActionButton,
          floatingActionButtonLocation: widget.floatingActionButtonLocation,
          backgroundColor: widget.backgroundColor ?? colors.background,
        );
      },
    );
  }
}
