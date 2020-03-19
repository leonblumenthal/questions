import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';



class CircleDiagram extends StatelessWidget {
  final Widget child;
  final double radius;

  CircleDiagram(this.child, {this.radius = 80});

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: CircleDiagramPainter([
          WeightedPaint(Colors.pinkAccent, 1),
          WeightedPaint(Colors.greenAccent, 3),
          WeightedPaint(Colors.orangeAccent, 4),
          WeightedPaint(Colors.indigoAccent, 2),
        ], radius),
        child: Container(
          width: 2 * radius,
          height: 2 * radius,
          child: Center(child: child),
        ),
      );
}

class CircleDiagramPainter extends CustomPainter {
  final List<WeightedPaint> paints;
  Rect outerRect;

  CircleDiagramPainter(this.paints, double radius) {
    // Sum up weights and compute circle section for each paint.
    var totalWeight = paints.map((it) => it.weight).reduce((a, b) => a + b);
    for (var p in paints) p.weight = 2 * pi * p.weight / totalWeight;

    outerRect = Rect.fromCircle(center: Offset(radius, radius), radius: radius);
  }

  @override
  void paint(Canvas canvas, Size size) {
    var angle = pi / 2;
    for (var p in paints) {
      canvas.drawArc(outerRect, angle, -p.weight, false, p);
      angle -= p.weight;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class WeightedPaint extends Paint {
  double weight;

  WeightedPaint(Color color, this.weight, {double strokeWidth = 6}) : super() {
    this.color = color;
    style = PaintingStyle.stroke;
    this.strokeWidth = strokeWidth;
  }
}
