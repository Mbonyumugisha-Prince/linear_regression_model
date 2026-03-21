import 'package:flutter/material.dart';

class WaveformBars extends StatefulWidget {
  /// compact = true → 5 narrow bars (fits inside 44px button)
  /// compact = false → 7 bars (decorative use, unconstrained)
  final bool compact;

  const WaveformBars({super.key, this.compact = false});

  @override
  State<WaveformBars> createState() => _WaveformBarsState();
}

class _WaveformBarsState extends State<WaveformBars>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // compact: 5 bars × (2px + 1px + 1px) = 20px total — fits in 42px
    // normal:  7 bars × (2.5px + 2px + 2px) = 45.5px — decorative only
    final heights = widget.compact
        ? [10.0, 18.0, 14.0, 20.0, 10.0]
        : [8.0, 16.0, 24.0, 18.0, 10.0, 20.0, 14.0];
    final barWidth = widget.compact ? 2.0 : 2.5;
    final margin = widget.compact ? 1.0 : 2.0;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(heights.length, (i) {
            final scale =
                i.isEven ? _animation.value : (1.5 - _animation.value);
            return Container(
              width: barWidth,
              height: heights[i] * scale,
              margin: EdgeInsets.symmetric(horizontal: margin),
              decoration: BoxDecoration(
                color: const Color.fromRGBO(255, 255, 255, 0.25),
                borderRadius: BorderRadius.circular(2),
              ),
            );
          }),
        );
      },
    );
  }
}
