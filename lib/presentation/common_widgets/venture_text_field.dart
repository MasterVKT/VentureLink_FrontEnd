import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_theme.dart';

class VentureTextField extends StatelessWidget {
  final String? label;
  final String? hint;
  final String? errorText;
  final bool obscureText;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onEditingComplete;
  final FormFieldValidator<String>? validator;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final bool enabled;
  final Widget? prefix;
  final Widget? suffix;
  final FocusNode? focusNode;
  final bool autofocus;
  final bool readOnly;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? contentPadding;
  final Color? backgroundColor;
  final double? elevation;
  final BorderRadius? borderRadius;
  final String? value;

  const VentureTextField({
    super.key,
    this.label,
    this.hint,
    this.errorText,
    this.obscureText = false,
    this.controller,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onEditingComplete,
    this.validator,
    this.inputFormatters,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.enabled = true,
    this.prefix,
    this.suffix,
    this.focusNode,
    this.autofocus = false,
    this.readOnly = false,
    this.onTap,
    this.contentPadding,
    this.backgroundColor,
    this.elevation,
    this.borderRadius,
    this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: elevation ?? 0,
      shape: RoundedRectangleBorder(
        borderRadius:
            borderRadius ?? BorderRadius.circular(AppTheme.defaultBorderRadius),
      ),
      color: backgroundColor ?? AppTheme.white,
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        onChanged: onChanged,
        onEditingComplete: onEditingComplete,
        validator: validator,
        inputFormatters: inputFormatters,
        maxLines: maxLines,
        minLines: minLines,
        maxLength: maxLength,
        enabled: enabled,
        focusNode: focusNode,
        autofocus: autofocus,
        readOnly: readOnly,
        onTap: onTap,
        initialValue: value,
        style: Theme.of(context).textTheme.bodyLarge,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          errorText: errorText,
          prefixIcon: prefix,
          suffixIcon: suffix,
          contentPadding: contentPadding ??
              const EdgeInsets.symmetric(
                horizontal: AppTheme.defaultPadding,
                vertical: 12,
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
          fillColor:
              enabled ? backgroundColor ?? AppTheme.white : AppTheme.lightGrey,
          labelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.darkGrey,
              ),
          hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppTheme.darkGrey.withValues(alpha: 0.5),
              ),
          errorStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.alertRed,
              ),
        ),
      ),
    );
  }
}
