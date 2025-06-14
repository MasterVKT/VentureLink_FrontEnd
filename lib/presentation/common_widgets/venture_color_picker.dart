import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../../core/theme/app_theme.dart';
import 'venture_button.dart';

class VentureColorPicker extends StatelessWidget {
  final Color? selectedColor;
  final String? label;
  final String? hint;
  final String? errorText;
  final ValueChanged<Color>? onColorSelected;
  final FormFieldValidator<Color>? validator;
  final bool enabled;
  final bool readOnly;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? contentPadding;
  final Color? backgroundColor;
  final double? elevation;
  final BorderRadius? borderRadius;
  final FocusNode? focusNode;
  final bool autofocus;
  final bool showClearButton;
  final String? buttonText;
  final IconData? buttonIcon;
  final VentureButtonType buttonType;
  final List<Color>? availableColors;

  const VentureColorPicker({
    super.key,
    this.selectedColor,
    this.label,
    this.hint,
    this.errorText,
    this.onColorSelected,
    this.validator,
    this.enabled = true,
    this.readOnly = false,
    this.onTap,
    this.contentPadding,
    this.backgroundColor,
    this.elevation,
    this.borderRadius,
    this.focusNode,
    this.autofocus = false,
    this.showClearButton = true,
    this.buttonText,
    this.buttonIcon,
    this.buttonType = VentureButtonType.primary,
    this.availableColors,
  });

  Future<void> _pickColor(BuildContext context) async {
    if (!enabled || readOnly) return;

    final Color? picked = await showDialog<Color>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Sélectionner une couleur',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppTheme.black,
                fontWeight: FontWeight.w600,
              ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (availableColors != null)
                Wrap(
                  spacing: AppTheme.defaultPadding / 2,
                  runSpacing: AppTheme.defaultPadding / 2,
                  children: [
                    ...availableColors!.map(
                      (color) => InkWell(
                        onTap: () => Navigator.of(context).pop(color),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(
                              AppTheme.defaultBorderRadius,
                            ),
                            border: Border.all(
                              color: AppTheme.mediumGrey,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              Padding(
                padding: const EdgeInsets.only(
                  top: AppTheme.defaultPadding,
                ),
                child: ColorPicker(
                  pickerColor: selectedColor ?? AppTheme.primaryBlue,
                  onColorChanged: (color) {
                    Navigator.of(context).pop(color);
                  },
                  enableAlpha: true,
                  displayThumbColor: true,
                  showLabel: true,
                  pickerAreaHeightPercent: 0.8,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Annuler',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppTheme.darkGrey,
                  ),
            ),
          ),
        ],
      ),
    );

    if (picked != null && picked != selectedColor) {
      onColorSelected?.call(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: AppTheme.defaultPadding / 2),
            child: Text(
              label!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.darkGrey,
                  ),
            ),
          ),
        Row(
          children: [
            if (selectedColor != null)
              Container(
                width: 40,
                height: 40,
                margin: const EdgeInsets.only(
                  right: AppTheme.defaultPadding,
                ),
                decoration: BoxDecoration(
                  color: selectedColor,
                  borderRadius: BorderRadius.circular(
                    AppTheme.defaultBorderRadius,
                  ),
                  border: Border.all(
                    color: AppTheme.mediumGrey,
                  ),
                ),
              ),
            Expanded(
              child: VentureButton(
                text: buttonText ?? 'Sélectionner une couleur',
                onPressed: () => _pickColor(context),
                type: buttonType,
                icon: buttonIcon ?? Icons.color_lens,
                isFullWidth: true,
              ),
            ),
          ],
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(
              top: AppTheme.defaultPadding / 2,
            ),
            child: Text(
              errorText!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.alertRed,
                  ),
            ),
          ),
      ],
    );
  }
}
