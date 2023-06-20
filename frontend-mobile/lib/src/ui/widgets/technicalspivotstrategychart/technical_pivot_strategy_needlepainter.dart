import 'dart:math';

import 'technicals_pivot_strategy_helper.dart';
import 'package:flutter/material.dart';

class TechnicalPivotStrategyNeedlePainter extends CustomPainter {
  final Paint needlePaint;
  Paint circlePaint = Paint();
  double value;
  int end = 60;
  Color color;
  Color innercirclecolor;

  TechnicalPivotStrategyNeedlePainter(
      {required this.value,
      required this.color,
      required this.innercirclecolor})
      : needlePaint = Paint() {
    needlePaint.color = color;
    needlePaint.style = PaintingStyle.fill;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final double radius = TechnicalsPivotStrategyHelper.getWidthForRadius(size);
    final double gamma = (2 / 3) * end;
    final double downSizedValue =
        ((value <= (end / 2)) ? value : value - (end / 2)) * (gamma / end);
    final double realValue =
        ((value <= (end / 2)) ? downSizedValue + gamma : downSizedValue) % end;

    canvas.save();
    canvas.translate(radius, radius);
    canvas.rotate(2 * pi * (realValue / end));

    final Path path = Path();
    path.moveTo(0.0, -radius - 5.0);
    path.lineTo(-2.5, -radius / 20.5);
    path.lineTo(2.5, -radius / 20.5);
    path.lineTo(2.5, -radius - 5.0);
    path.close();

    canvas.drawPath(path, needlePaint);
    canvas.drawCircle(const Offset(0.0, 0.0), 4.0, needlePaint);

    circlePaint.color = innercirclecolor;
    circlePaint.style = PaintingStyle.fill;

    canvas.drawCircle(const Offset(0.0, 0.0), 2.0, circlePaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(TechnicalPivotStrategyNeedlePainter oldDelegate) {
    return false;
  }
}
