import 'package:flutter/material.dart';

class WaveGradientShader extends StatefulWidget {
  final Widget child;
  const WaveGradientShader({required this.child, super.key});

  @override
  State<WaveGradientShader> createState() => _WaveGradientShaderState();
}

class _WaveGradientShaderState extends State<WaveGradientShader> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              stops: [0.0, _controller.value, 1.0],
              colors: const [Colors.transparent, Colors.blue, Colors.transparent],
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}
