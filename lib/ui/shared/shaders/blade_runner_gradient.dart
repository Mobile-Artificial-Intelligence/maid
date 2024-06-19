import 'package:flutter/material.dart';

class BladeRunnerGradientShader extends StatelessWidget {
  final List<double>? stops;
  final Widget child;

  const BladeRunnerGradientShader({super.key, required this.child, this.stops});

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        colors: const [
          Color.fromARGB(255, 0, 200, 255),
          Color.fromARGB(255, 255, 80, 200)
        ],
        stops: stops,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(bounds),
      blendMode: BlendMode.srcIn,
      child: child,
    );
  }

}