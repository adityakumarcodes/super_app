import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:material_ui/material_ui.dart';
import 'package:google_fonts/google_fonts.dart';

class CircleText extends StatefulWidget {
  const CircleText({super.key, required this.child});

  final Widget child;

  @override
  State<CircleText> createState() => _CircleTextState();
}

class _CircleTextState extends State<CircleText>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;
  late List<TextPainter> letters;
  Color? _textColor;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final color = Theme.of(context).colorScheme.onSurface;
    if (color == _textColor) return;

    if (_textColor != null) {
      for (final letter in letters) {
        letter.dispose();
      }
    }

    final style = GoogleFonts.poppins(
      fontSize: 20,
      fontWeight: FontWeight.w500,
      letterSpacing: 1,
      color: color,
    );

    letters = 'DAY STARTS WITH YOU'.split('').map((character) {
      return TextPainter(
        text: TextSpan(text: character, style: style),
        textDirection: ui.TextDirection.ltr,
      )..layout();
    }).toList();

    _textColor = color;
  }

  @override
  void dispose() {
    controller.dispose();

    for (final letter in letters) {
      letter.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = math.min(constraints.maxWidth, constraints.maxHeight);

        final radius = size * 0.30;
        final gap = radius * 0.18;
        final innerRadius = radius - gap;

        return SizedBox(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: Size(constraints.maxWidth, constraints.maxHeight),
                painter: CircleTextPainter(
                  animation: controller,
                  letters: letters,
                  color: _textColor!,
                ),
              ),

              // Child constrained inside the inner circle
              SizedBox(
                width: innerRadius * 2,
                height: innerRadius * 2,
                child: ClipOval(child: Center(child: widget.child)),
              ),
            ],
          ),
        );
      },
    );
  }
}

class CircleTextPainter extends CustomPainter {
  CircleTextPainter({
    required this.animation,
    required this.letters,
    required this.color,
  }) : super(repaint: animation);

  final Animation<double> animation;
  final List<TextPainter> letters;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) * 0.30;
    final gap = radius * 0.18;

    final circlePaint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Inner and outer circles
    canvas.drawCircle(center, radius - gap, circlePaint);
    canvas.drawCircle(center, radius + gap, circlePaint);

    final textWidth = letters.fold<double>(
      0,
      (total, letter) => total + letter.width,
    );

    final centerAngle = math.pi / 2 + animation.value * 2 * math.pi;
    var distanceAlongText = 0.0;

    for (final letter in letters) {
      final letterMiddle = distanceAlongText + letter.width / 2;
      final angle = centerAngle + (textWidth / 2 - letterMiddle) / radius;

      final position = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );

      canvas.save();
      canvas.translate(position.dx, position.dy);
      canvas.rotate(angle - math.pi / 2);
      letter.paint(canvas, Offset(-letter.width / 2, -letter.height / 2));
      canvas.restore();

      distanceAlongText += letter.width;
    }

    // Rotating dots
    final dotPaint = Paint()..color = color;
    final dotAngle = (textWidth / 2 + 15) / radius;

    for (final angle in [centerAngle - dotAngle, centerAngle + dotAngle]) {
      canvas.drawCircle(
        Offset(
          center.dx + radius * math.cos(angle),
          center.dy + radius * math.sin(angle),
        ),
        3,
        dotPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CircleTextPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.letters != letters;
}
