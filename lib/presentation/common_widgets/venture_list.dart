import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class VentureList extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsetsGeometry? padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final ScrollController? controller;
  final bool primary;
  final bool addAutomaticKeepAlives;
  final bool addRepaintBoundaries;
  final Widget? separator;
  final bool addSemanticIndexes;
  final DragStartBehavior dragStartBehavior;
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;
  final String? restorationId;
  final Clip clipBehavior;
  final bool reverse;

  const VentureList({
    super.key,
    required this.children,
    this.padding,
    this.shrinkWrap = false,
    this.physics,
    this.controller,
    this.primary = false,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.separator,
    this.addSemanticIndexes = true,
    this.dragStartBehavior = DragStartBehavior.start,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.restorationId,
    this.clipBehavior = Clip.hardEdge,
    this.reverse = false,
  });

  @override
  Widget build(BuildContext context) {
    if (separator != null) {
      return ListView.separated(
        padding: padding ?? const EdgeInsets.all(AppTheme.defaultPadding),
        shrinkWrap: shrinkWrap,
        physics: physics,
        controller: controller,
        primary: primary,
        addAutomaticKeepAlives: addAutomaticKeepAlives,
        addRepaintBoundaries: addRepaintBoundaries,
        addSemanticIndexes: addSemanticIndexes,
        dragStartBehavior: dragStartBehavior,
        keyboardDismissBehavior: keyboardDismissBehavior,
        restorationId: restorationId,
        clipBehavior: clipBehavior,
        reverse: reverse,
        itemCount: children.length,
        separatorBuilder: (context, index) => separator!,
        itemBuilder: (context, index) => children[index],
      );
    }

    return ListView(
      padding: padding ?? const EdgeInsets.all(AppTheme.defaultPadding),
      shrinkWrap: shrinkWrap,
      physics: physics,
      controller: controller,
      primary: primary,
      addAutomaticKeepAlives: addAutomaticKeepAlives,
      addRepaintBoundaries: addRepaintBoundaries,
      addSemanticIndexes: addSemanticIndexes,
      dragStartBehavior: dragStartBehavior,
      keyboardDismissBehavior: keyboardDismissBehavior,
      restorationId: restorationId,
      clipBehavior: clipBehavior,
      reverse: reverse,
      children: children,
    );
  }
}

class VentureListTile extends StatelessWidget {
  final Widget? leading;
  final Widget? title;
  final Widget? subtitle;
  final Widget? trailing;
  final bool isThreeLine;
  final bool? dense;
  final VisualDensity? visualDensity;
  final ShapeBorder? shape;
  final EdgeInsetsGeometry? contentPadding;
  final bool enabled;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final MouseCursor? mouseCursor;
  final bool selected;
  final Color? focusColor;
  final Color? hoverColor;
  final FocusNode? focusNode;
  final bool autofocus;
  final Color? tileColor;
  final Color? selectedTileColor;
  final bool? enableFeedback;
  final double? horizontalTitleGap;
  final double? minVerticalPadding;
  final double? minLeadingWidth;

  const VentureListTile({
    super.key,
    this.leading,
    this.title,
    this.subtitle,
    this.trailing,
    this.isThreeLine = false,
    this.dense,
    this.visualDensity,
    this.shape,
    this.contentPadding,
    this.enabled = true,
    this.onTap,
    this.onLongPress,
    this.mouseCursor,
    this.selected = false,
    this.focusColor,
    this.hoverColor,
    this.focusNode,
    this.autofocus = false,
    this.tileColor,
    this.selectedTileColor,
    this.enableFeedback,
    this.horizontalTitleGap,
    this.minVerticalPadding,
    this.minLeadingWidth,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: leading,
      title: title,
      subtitle: subtitle,
      trailing: trailing,
      isThreeLine: isThreeLine,
      dense: dense,
      visualDensity: visualDensity,
      shape: shape ??
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.defaultBorderRadius),
          ),
      contentPadding: contentPadding ??
          const EdgeInsets.symmetric(
            horizontal: AppTheme.defaultPadding,
            vertical: AppTheme.defaultPadding / 2,
          ),
      enabled: enabled,
      onTap: onTap,
      onLongPress: onLongPress,
      mouseCursor: mouseCursor,
      selected: selected,
      focusColor: focusColor,
      hoverColor: hoverColor,
      focusNode: focusNode,
      autofocus: autofocus,
      tileColor: tileColor,
      selectedTileColor: selectedTileColor,
      enableFeedback: enableFeedback,
      horizontalTitleGap: horizontalTitleGap,
      minVerticalPadding: minVerticalPadding,
      minLeadingWidth: minLeadingWidth,
    );
  }
}
