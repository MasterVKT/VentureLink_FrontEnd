import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_theme.dart';

class VentureSearchField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hint;
  final String? label;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final VoidCallback? onSearch;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final bool autofocus;
  final bool enabled;
  final bool readOnly;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? contentPadding;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final TextCapitalization textCapitalization;
  final TextInputType? keyboardType;
  final bool obscureText;
  final String? errorText;
  final FormFieldValidator<String>? validator;
  final bool showClearButton;
  final bool showSearchButton;
  final Color? backgroundColor;
  final double? elevation;
  final BorderRadius? borderRadius;

  const VentureSearchField({
    super.key,
    this.controller,
    this.hint,
    this.label,
    this.onChanged,
    this.onClear,
    this.onSearch,
    this.textInputAction,
    this.focusNode,
    this.autofocus = false,
    this.enabled = true,
    this.readOnly = false,
    this.onTap,
    this.contentPadding,
    this.inputFormatters,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.textCapitalization = TextCapitalization.none,
    this.keyboardType,
    this.obscureText = false,
    this.errorText,
    this.validator,
    this.showClearButton = true,
    this.showSearchButton = true,
    this.backgroundColor,
    this.elevation,
    this.borderRadius,
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
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        autofocus: autofocus,
        enabled: enabled,
        readOnly: readOnly,
        onTap: onTap,
        onChanged: onChanged,
        textInputAction: textInputAction ?? TextInputAction.search,
        onFieldSubmitted: (_) => onSearch?.call(),
        inputFormatters: inputFormatters,
        maxLines: maxLines,
        minLines: minLines,
        maxLength: maxLength,
        textCapitalization: textCapitalization,
        keyboardType: keyboardType,
        obscureText: obscureText,
        validator: validator,
        style: Theme.of(context).textTheme.bodyLarge,
        decoration: InputDecoration(
          hintText: hint,
          labelText: label,
          errorText: errorText,
          contentPadding: contentPadding ??
              const EdgeInsets.symmetric(
                horizontal: AppTheme.defaultPadding,
                vertical: AppTheme.defaultPadding / 2,
              ),
          border: OutlineInputBorder(
            borderRadius: borderRadius ??
                BorderRadius.circular(AppTheme.defaultBorderRadius),
            borderSide: const BorderSide(color: AppTheme.mediumGrey),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: borderRadius ??
                BorderRadius.circular(AppTheme.defaultBorderRadius),
            borderSide: const BorderSide(color: AppTheme.mediumGrey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: borderRadius ??
                BorderRadius.circular(AppTheme.defaultBorderRadius),
            borderSide: const BorderSide(color: AppTheme.primaryBlue),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: borderRadius ??
                BorderRadius.circular(AppTheme.defaultBorderRadius),
            borderSide: const BorderSide(color: AppTheme.alertRed),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: borderRadius ??
                BorderRadius.circular(AppTheme.defaultBorderRadius),
            borderSide: const BorderSide(color: AppTheme.alertRed),
          ),
          filled: true,
          fillColor: enabled ? AppTheme.white : AppTheme.lightGrey,
          labelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.darkGrey,
              ),
          hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppTheme.darkGrey.withValues(alpha: 0.5),
              ),
          errorStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.alertRed,
              ),
          prefixIcon: const Icon(
            Icons.search,
            color: AppTheme.darkGrey,
          ),
          suffixIcon: showClearButton && controller?.text.isNotEmpty == true
              ? IconButton(
                  icon: const Icon(
                    Icons.clear,
                    color: AppTheme.darkGrey,
                  ),
                  onPressed: () {
                    controller?.clear();
                    onClear?.call();
                  },
                )
              : null,
        ),
      ),
    );
  }
}
