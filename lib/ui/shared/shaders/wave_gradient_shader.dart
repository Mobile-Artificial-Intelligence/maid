import 'package:flutter/material.dart';

class WaveGradientShader extends StatefulWidget {
  final Widget child;
  final double durationFactor;
  final double animationOffset;

  const WaveGradientShader({
    required this.child,
    required this.durationFactor,
    required this.animationOffset,
    super.key,
  });

  @override
  State<WaveGradientShader> createState() => _WaveGradientShaderState();
}

class _WaveGradientShaderState extends State<WaveGradientShader> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      value: widget.animationOffset,
      duration: Duration(milliseconds: (3000 * widget.durationFactor).clamp(2000, 4000).toInt()),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final boundary = Theme.of(context).colorScheme.surfaceDim;
    final wave = Theme.of(context).colorScheme.secondary;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              stops:  [0.0, _controller.value, 1.0],
              colors: [
                boundary,
                wave,
                boundary,
              ],
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}
