import 'package:flutter/material.dart';

class GradientText extends StatelessWidget {
  const GradientText({
    Key? key,
    required this.text,
    this.style,
    required this.gradient,
  }) : super(key: key);
  final String text;
  final TextStyle? style;
  final Gradient gradient;
  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => gradient.createShader(
        Rect.fromCircle(center: Offset(bounds.width/2, bounds.height/2), radius: bounds.width*(3/5))
        //Rect.fromCenter(center: Offset(bounds.width/2, bounds.height/2), width: 2*bounds.width, height: bounds.height)
        //Rect.fromLTRB(bounds.width, bounds.height, 0, 0)
        //Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: Text(text, style: style),
    );
  }
}