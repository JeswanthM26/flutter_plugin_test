import "dart:math" as math;
import "package:flutter/material.dart";
import "package:flutter/scheduler.dart";

///  class to show a loading  animation during payment processing.
class PaymentInProgressUI extends StatefulWidget {
  /// Creates a PaymentInProgressUI widget.
  const PaymentInProgressUI({
    final Color? loaderColor,
    super.key,
  }) : _loaderColor = loaderColor ?? Colors.blue;

  final Color _loaderColor;

  @override
  State<PaymentInProgressUI> createState() => _PaymentInProgressUIState();
}

class _PaymentInProgressUIState extends State<PaymentInProgressUI>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progress;
  late final Stopwatch _stopwatch;
late final Ticker _ticker;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900), // Adjust for speed
    );

    _progress = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    )..addStatusListener((final AnimationStatus status) {
        if (status == AnimationStatus.completed) {
          _controller..reset()
          ..forward();
        }
      });
    _stopwatch = Stopwatch()..start();
    _controller.forward();

      _ticker = Ticker((_) {
    setState(() {}); // Rebuilds every frame to update time
  })..start();
  }

  @override
  void dispose() {
    _controller.dispose();
    _ticker.dispose();
    _stopwatch.stop();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
  final int seconds = _stopwatch.elapsed.inSeconds;
  final int milliseconds = (_stopwatch.elapsed.inMilliseconds % 1000) ~/ 10;

  return Center(
    child: Column(
      children: <Widget>[
        SizedBox(
          height: 150,
          width: 150,
          child: AnimatedBuilder(
            animation: _progress,
            builder: (final BuildContext context, final Widget? child) => 
            CustomPaint(
                painter: PaymentProgressPainter(
                  progress: _progress.value,
                  progressColor: widget._loaderColor,
                  baseColor: Colors.grey.shade300,
                  strokeWidth: 10,
                ),
                child: Center(
                  child: Text(
                    '$seconds.${milliseconds.toString().padLeft(2, '0')} s',
                    style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ),
        ),
                  const SizedBox(height: 20),
          const Text(
            "Processing Payment...",
            style: TextStyle(fontSize: 20, color: Colors.black54),
          ),
      ],
    ),
  );
}
}

/// class to manage GIF overlay animations.
class PaymentProgressPainter extends CustomPainter {
  /// Creates a PaymentProgressPainter.
  PaymentProgressPainter({
    required this.progress,
    required this.progressColor,
    required this.baseColor,
    required this.strokeWidth,
  });

  /// The progress value (0.0 to 1.0).
  final double progress;
  /// The color of the progress arc.
  final Color progressColor;
  /// The base color of the circle.
  final Color baseColor;
  /// The stroke width of the circle and arc.
  final double strokeWidth;

  @override
  void paint(final Canvas canvas, final Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius =
        math.min(size.width, size.height) / 2 - strokeWidth / 2;

    final Paint basePaint = Paint()
      ..color = baseColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final Paint progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    // Draw base circle
    canvas.drawCircle(center, radius, basePaint);

    // Draw arc (starts at 12 o'clock, sweeps clockwise)
    final double sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, // 12 o'clock
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant final PaymentProgressPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.baseColor != baseColor ||
      oldDelegate.progressColor != progressColor ||
      oldDelegate.strokeWidth != strokeWidth;
}
