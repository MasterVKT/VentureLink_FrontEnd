import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class VentureAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final double elevation;
  final Color? backgroundColor;
  final PreferredSizeWidget? bottom;
  final bool automaticallyImplyLeading;
  final Widget? flexibleSpace;
  final double? titleSpacing;
  final double? leadingWidth;
  final TextStyle? titleStyle;
  final Color? iconThemeColor;
  final double? toolbarHeight;

  const VentureAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.centerTitle = true,
    this.elevation = 0,
    this.backgroundColor,
    this.bottom,
    this.automaticallyImplyLeading = true,
    this.flexibleSpace,
    this.titleSpacing,
    this.leadingWidth,
    this.titleStyle,
    this.iconThemeColor,
    this.toolbarHeight,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: titleStyle ??
            Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.black,
                  fontWeight: FontWeight.w600,
                ),
      ),
      actions: actions,
      leading: leading,
      centerTitle: centerTitle,
      elevation: elevation,
      backgroundColor: backgroundColor ?? AppTheme.white,
      bottom: bottom,
      automaticallyImplyLeading: automaticallyImplyLeading,
      flexibleSpace: flexibleSpace,
      titleSpacing: titleSpacing,
      leadingWidth: leadingWidth,
      toolbarHeight: toolbarHeight,
      iconTheme: IconThemeData(
        color: iconThemeColor ?? AppTheme.black,
      ),
      shape: const Border(
        bottom: BorderSide(
          color: AppTheme.lightGrey,
          width: 1,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
        toolbarHeight ?? kToolbarHeight + (bottom?.preferredSize.height ?? 0),
      );
}

class VentureSliverAppBar extends StatelessWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final double elevation;
  final Color? backgroundColor;
  final PreferredSizeWidget? bottom;
  final bool automaticallyImplyLeading;
  final Widget? flexibleSpace;
  final double? titleSpacing;
  final double? leadingWidth;
  final TextStyle? titleStyle;
  final Color? iconThemeColor;
  final double? toolbarHeight;
  final bool pinned;
  final bool floating;
  final bool snap;
  final double expandedHeight;

  const VentureSliverAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.centerTitle = true,
    this.elevation = 0,
    this.backgroundColor,
    this.bottom,
    this.automaticallyImplyLeading = true,
    this.flexibleSpace,
    this.titleSpacing,
    this.leadingWidth,
    this.titleStyle,
    this.iconThemeColor,
    this.toolbarHeight,
    this.pinned = true,
    this.floating = false,
    this.snap = false,
    this.expandedHeight = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      title: Text(
        title,
        style: titleStyle ??
            Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.black,
                  fontWeight: FontWeight.w600,
                ),
      ),
      actions: actions,
      leading: leading,
      centerTitle: centerTitle,
      elevation: elevation,
      backgroundColor: backgroundColor ?? AppTheme.white,
      bottom: bottom,
      automaticallyImplyLeading: automaticallyImplyLeading,
      flexibleSpace: flexibleSpace,
      titleSpacing: titleSpacing ?? NavigationToolbar.kMiddleSpacing,
      leadingWidth: leadingWidth ?? kToolbarHeight,
      toolbarHeight: toolbarHeight ?? kToolbarHeight,
      iconTheme: IconThemeData(
        color: iconThemeColor ?? AppTheme.black,
      ),
      shape: const Border(
        bottom: BorderSide(
          color: AppTheme.lightGrey,
          width: 1,
        ),
      ),
      pinned: pinned,
      floating: floating,
      snap: snap,
      expandedHeight: expandedHeight,
    );
  }
}
