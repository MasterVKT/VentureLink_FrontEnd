import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class VentureGrid extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsetsGeometry? padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final ScrollController? controller;
  final bool primary;
  final bool addAutomaticKeepAlives;
  final bool addRepaintBoundaries;
  final bool addSemanticIndexes;
  final DragStartBehavior dragStartBehavior;
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;
  final String? restorationId;
  final Clip clipBehavior;
  final bool reverse;
  final int crossAxisCount;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final double childAspectRatio;
  final double mainAxisExtent;
  final bool semanticChildCount;

  const VentureGrid({
    super.key,
    required this.children,
    this.padding,
    this.shrinkWrap = false,
    this.physics,
    this.controller,
    this.primary = false,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    this.dragStartBehavior = DragStartBehavior.start,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.restorationId,
    this.clipBehavior = Clip.hardEdge,
    this.reverse = false,
    this.crossAxisCount = 2,
    this.mainAxisSpacing = AppTheme.defaultPadding,
    this.crossAxisSpacing = AppTheme.defaultPadding,
    this.childAspectRatio = 1.0,
    this.mainAxisExtent = 0.0,
    this.semanticChildCount = true,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
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
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: mainAxisSpacing,
        crossAxisSpacing: crossAxisSpacing,
        childAspectRatio: childAspectRatio,
        mainAxisExtent: mainAxisExtent,
      ),
      itemCount: children.length,
      itemBuilder: (context, index) => children[index],
    );
  }
}

class VentureGridTile extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final double? elevation;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;
  final bool isLoading;
  final Widget? loadingWidget;

  const VentureGridTile({
    super.key,
    required this.child,
    this.padding,
    this.backgroundColor,
    this.elevation,
    this.borderRadius,
    this.onTap,
    this.isLoading = false,
    this.loadingWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: elevation ?? 2,
      shape: RoundedRectangleBorder(
        borderRadius:
            borderRadius ?? BorderRadius.circular(AppTheme.defaultBorderRadius),
      ),
      color: backgroundColor ?? AppTheme.white,
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius:
            borderRadius ?? BorderRadius.circular(AppTheme.defaultBorderRadius),
        child: Stack(
          children: [
            Padding(
              padding: padding ?? const EdgeInsets.all(AppTheme.defaultPadding),
              child: child,
            ),
            if (isLoading)
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.white.withOpacity(0.7),
                  borderRadius: borderRadius ??
                      BorderRadius.circular(AppTheme.defaultBorderRadius),
                ),
                child: Center(
                  child: loadingWidget ??
                      const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.primaryBlue,
                        ),
                      ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
