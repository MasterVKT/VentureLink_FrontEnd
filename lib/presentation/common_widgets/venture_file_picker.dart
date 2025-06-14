import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../core/theme/app_theme.dart';
import 'venture_button.dart';

class VentureFilePicker extends StatelessWidget {
  final String? label;
  final String? hint;
  final String? errorText;
  final ValueChanged<PlatformFile>? onFileSelected;
  final FormFieldValidator<PlatformFile>? validator;
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
  final List<String>? allowedExtensions;
  final String? dialogTitle;
  final String? buttonText;
  final IconData? buttonIcon;
  final VentureButtonType buttonType;
  final bool allowMultiple;
  final FileType type;
  final bool withData;
  final bool withReadStream;
  final bool allowCompression;
  final bool readSequential;
  final bool lockParentWindow;
  final bool clearCache;

  const VentureFilePicker({
    super.key,
    this.label,
    this.hint,
    this.errorText,
    this.onFileSelected,
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
    this.allowedExtensions,
    this.dialogTitle,
    this.buttonText,
    this.buttonIcon,
    this.buttonType = VentureButtonType.primary,
    this.allowMultiple = false,
    this.type = FileType.any,
    this.withData = false,
    this.withReadStream = false,
    this.allowCompression = true,
    this.readSequential = false,
    this.lockParentWindow = false,
    this.clearCache = false,
  });

  Future<void> _pickFile(BuildContext context) async {
    if (!enabled || readOnly) return;

    try {
      final result = await FilePicker.platform.pickFiles(
        type: type,
        allowMultiple: allowMultiple,
        allowedExtensions: allowedExtensions,
        withData: withData,
        withReadStream: withReadStream,
        allowCompression: allowCompression,
        readSequential: readSequential,
        lockParentWindow: lockParentWindow,
        dialogTitle: dialogTitle,
      );

      if (result != null && result.files.isNotEmpty) {
        onFileSelected?.call(result.files.first);
      }
    } catch (e) {
      // Handle error
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
        VentureButton(
          text: buttonText ?? 'Sélectionner un fichier',
          onPressed: () => _pickFile(context),
          type: buttonType,
          icon: buttonIcon ?? Icons.attach_file,
          isFullWidth: true,
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
