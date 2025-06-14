import 'package:flutter/material.dart';
import 'dart:math' show cos, sin;
import '../../core/theme/app_theme.dart';

/// Widget d'indicateur de chargement personnalisé pour VentureLink
class VLLoadingIndicator extends StatefulWidget {
  final double size;
  final Color? color;
  final String? message;
  final bool showMessage;

  const VLLoadingIndicator({
    super.key,
    this.size = 40.0,
    this.color,
    this.message,
    this.showMessage = false,
  });

  @override
  State<VLLoadingIndicator> createState() => _VLLoadingIndicatorState();
}

class _VLLoadingIndicatorState extends State<VLLoadingIndicator>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<AppThemeExtension>();
    final indicatorColor =
        widget.color ?? (theme != null ? AppTheme.primaryColor : Colors.blue);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: widget.size,
          height: widget.size,
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return CustomPaint(
                painter: _VLLoadingPainter(
                  progress: _animation.value,
                  color: indicatorColor,
                ),
              );
            },
          ),
        ),
        if (widget.showMessage && widget.message != null) ...[
          const SizedBox(height: 16),
          Text(
            widget.message!,
            style: TextStyle(
              color: theme?.textSecondaryColor ?? Colors.grey,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

/// Painter personnalisé pour l'indicateur de chargement VentureLink
class _VLLoadingPainter extends CustomPainter {
  final double progress;
  final Color color;

  _VLLoadingPainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Peinture pour le cercle de fond
    final backgroundPaint = Paint()
      ..color = color.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    // Peinture pour l'arc de progression
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    // Dessiner le cercle de fond
    canvas.drawCircle(center, radius - 2, backgroundPaint);

    // Dessiner l'arc de progression
    final sweepAngle = 2 * 3.14159 * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 2),
      -3.14159 / 2, // Commencer en haut
      sweepAngle,
      false,
      progressPaint,
    );

    // Ajouter un point lumineux à la fin de l'arc
    if (progress > 0) {
      final endAngle = -3.14159 / 2 + sweepAngle;
      final endPoint = Offset(
        center.dx + (radius - 2) * cos(endAngle),
        center.dy + (radius - 2) * sin(endAngle),
      );

      final dotPaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      canvas.drawCircle(endPoint, 4, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _VLLoadingPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}

/// Widget d'indicateur de chargement simple
class VLSimpleLoadingIndicator extends StatelessWidget {
  final double size;
  final Color? color;

  const VLSimpleLoadingIndicator({
    super.key,
    this.size = 24.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<AppThemeExtension>();

    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: 2.0,
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? (theme != null ? AppTheme.primaryColor : Colors.blue),
        ),
      ),
    );
  }
}

/// Widget d'indicateur de chargement avec overlay
class VLLoadingOverlay extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final String? message;

  const VLLoadingOverlay({
    super.key,
    required this.child,
    required this.isLoading,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black.withOpacity(0.3),
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: VLLoadingIndicator(
                  message: message,
                  showMessage: message != null,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
