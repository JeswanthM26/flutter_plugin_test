import "package:flutter/material.dart";

/// AnimatedScannerLine is a widget that displays an animated scanner line
class AnimatedScannerLine extends StatefulWidget {
  ///  AnimatedScannerLine constructor accepts cropSize
  /// and isMultiScan parameters
  const AnimatedScannerLine({
    required final double cropSize,
    required final bool isMultiScan,
    final Color lineColor = Colors.redAccent,
    super.key,
  }) : _cropSize = cropSize,
       _isMultiScan = isMultiScan,
       _lineColor = lineColor;
  final double _cropSize;
  final bool _isMultiScan;
  final Color _lineColor;

  @override
  State<AnimatedScannerLine> createState() => _AnimatedScannerLineState();
}

class _AnimatedScannerLineState extends State<AnimatedScannerLine>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5000),
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: 2,
      end: widget._cropSize - 2, // 2 is the red line height
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.linear));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    if (widget._isMultiScan) {
      return const SizedBox.shrink();
    }

    return Stack(
      children: <Widget>[
        Positioned(
          top: (MediaQuery.of(context).size.height - widget._cropSize) / 8,
          left: (MediaQuery.of(context).size.width - widget._cropSize) / 2,
          child: SizedBox(
            width: widget._cropSize,
            height: widget._cropSize,
            child: AnimatedBuilder(
              animation: _animation,
              builder: (_, final __) => Stack(
                children: <Widget>[
                  Positioned(
                    top: _animation.value,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 2,
                      decoration: BoxDecoration(
                        color: widget._lineColor,
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color:  widget._lineColor,
                            blurRadius: 4,
                            blurStyle: BlurStyle.outer,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
