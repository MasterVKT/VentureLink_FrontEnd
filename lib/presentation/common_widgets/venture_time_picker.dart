import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import 'venture_text_field.dart';

class VentureTimePicker extends StatelessWidget {
  final TimeOfDay? selectedTime;
  final String? label;
  final String? hint;
  final String? errorText;
  final ValueChanged<TimeOfDay?>? onTimeSelected;
  final FormFieldValidator<TimeOfDay>? validator;
  final bool enabled;
  final bool readOnly;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? contentPadding;
  final Color? backgroundColor;
  final double? elevation;
  final BorderRadius? borderRadius;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final bool autofocus;
  final bool showClearButton;
  final String? format;

  const VentureTimePicker({
    super.key,
    this.selectedTime,
    this.label,
    this.hint,
    this.errorText,
    this.onTimeSelected,
    this.validator,
    this.enabled = true,
    this.readOnly = false,
    this.onTap,
    this.contentPadding,
    this.backgroundColor,
    this.elevation,
    this.borderRadius,
    this.controller,
    this.focusNode,
    this.autofocus = false,
    this.showClearButton = true,
    this.format,
  });

  Future<void> _selectTime(BuildContext context) async {
    if (!enabled || readOnly) return;

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryBlue,
              onPrimary: AppTheme.white,
              surface: AppTheme.white,
              onSurface: AppTheme.black,
            ),
            dialogBackgroundColor: AppTheme.white,
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != selectedTime) {
      onTimeSelected?.call(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final timeFormat = format ?? 'HH:mm';
    final displayTime = selectedTime != null
        ? DateFormat(timeFormat).format(
            DateTime(2024, 1, 1, selectedTime!.hour, selectedTime!.minute),
          )
        : '';

    return VentureTextField(
      controller: controller,
      label: label,
      hint: hint,
      errorText: errorText,
      enabled: enabled,
      readOnly: true,
      onTap: () => _selectTime(context),
      contentPadding: contentPadding,
      backgroundColor: backgroundColor,
      elevation: elevation,
      borderRadius: borderRadius,
      focusNode: focusNode,
      autofocus: autofocus,
      value: displayTime,
      prefix: const Icon(
        Icons.access_time,
        color: AppTheme.darkGrey,
      ),
      suffix: showClearButton && selectedTime != null
          ? IconButton(
              icon: const Icon(
                Icons.clear,
                color: AppTheme.darkGrey,
              ),
              onPressed: () {
                onTimeSelected?.call(null);
              },
            )
          : null,
      validator: validator != null
          ? (value) {
              if (value == null || value.isEmpty) {
                return validator!(null);
              }
              try {
                final time = DateFormat(timeFormat).parse(value);
                return validator!(
                  TimeOfDay(hour: time.hour, minute: time.minute),
                );
              } catch (e) {
                return 'Format d\'heure invalide';
              }
            }
          : null,
      onChanged: (value) {
        if (value.isEmpty) {
          onTimeSelected?.call(null);
        } else {
          try {
            final time = DateFormat(timeFormat).parse(value);
            onTimeSelected?.call(
              TimeOfDay(hour: time.hour, minute: time.minute),
            );
          } catch (e) {
            // Ignore invalid time format
          }
        }
      },
    );
  }
}
