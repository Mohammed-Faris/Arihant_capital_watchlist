import 'dart:math';

import 'package:flutter/material.dart';

import '../../screens/acml_app.dart';
import '../../styles/app_color.dart';
import '../../styles/app_widget_size.dart';
import 'technicals_pivot_strategy_helper.dart';

class TechnicalPivotStrategyArcPainter extends CustomPainter {
  late ThemeData themeData;
  late Color leftSideAreaColor;
  late Color rightSideAreaColor;
  late double width;
  late List<String> pivotPointsList;
  double angle = TechnicalsPivotStrategyHelper.getAngel();

  TechnicalPivotStrategyArcPainter(
      {required this.themeData,
      required this.leftSideAreaColor,
      required this.rightSideAreaColor,
      required this.width,
      required this.pivotPointsList});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint dividerPaint = Paint()
      ..color = Theme.of(navigatorKey.currentContext!).scaffoldBackgroundColor;
    final Offset center = TechnicalsPivotStrategyHelper.centerOffet(size);
    final double radius = min(
        TechnicalsPivotStrategyHelper.getWidthForRadius(size),
        TechnicalsPivotStrategyHelper.getheightForRadius(size));
    TextPainter textPainter;

    textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.rtl,
    );
    final Paint left = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [
          themeData.colorScheme.background,
          AppColors().positiveColor,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..color = leftSideAreaColor
      ..strokeCap = StrokeCap.butt
      ..style = PaintingStyle.stroke
      ..strokeWidth = width;

    final Paint right = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.topRight,
        colors: [
          themeData.colorScheme.background,
          AppColors.negativeColor,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..color = rightSideAreaColor
      ..strokeCap = StrokeCap.butt
      ..style = PaintingStyle.stroke
      ..strokeWidth = width;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      30 * angle,
      15 * angle,
      false,
      left,
    );

    canvas.drawArc(
      Rect.fromCircle(
        center: center,
        radius: radius,
      ),
      45 * angle,
      15 * angle,
      false,
      right,
    );

    canvas.save();
    canvas.translate(radius, radius);
    canvas.rotate(-0.1);
    for (int i = -1; i < 59; i++) {
      if (i % 5 == 0) {
        if (i >= 0 && i <= 12 || i >= 46 && i < 60) {
          dividerPaint.strokeWidth = 12;
          canvas.drawLine(
              Offset(0.0, -radius - 9), Offset(0.0, -radius + 9), dividerPaint);
          canvas.save();
          canvas.rotate(angle * i);
          canvas.restore();
        }
      }
      canvas.rotate(angle);
    }

    canvas.translate(radius, radius);
    canvas.rotate(0.1);
    int pivotPosition = 0;
    int leftSidePosition = 6;
    for (int i = 0; i < 56; i++) {
      if (i % 5 == 0) {
        if (i >= 0 && i < 20 || (i >= 45 && i <= 55)) {
          var dividerMarkLength = 30.0;
          dividerPaint.strokeWidth = 5.0;
          dividerPaint.color =
              Theme.of(navigatorKey.currentContext!).scaffoldBackgroundColor;
          canvas.drawLine(Offset(0.0, -radius - 5),
              Offset(0.0, -radius - 25 + dividerMarkLength), dividerPaint);

          // String? label = 'S' + i.toString(); //this.value.toStringAsFixed(1);
          canvas.save();
          canvas.translate(0.0, -radius * 1.1 - 15.0);

          String? label;
          if (i >= 45 && i <= 55) {
            label = pivotPointsList[leftSidePosition];
            leftSidePosition--;
          } else if (i >= 5 && i <= 15) {
            label = pivotPointsList[pivotPosition];
            pivotPosition++;
          } else {
            label = pivotPointsList[pivotPosition];
            pivotPosition++;
          }

          textPainter.text = TextSpan(
            text: label,
            style: label == "Pivot"
                ? TextStyle(
                    color: Theme.of(navigatorKey.currentContext!)
                        .textTheme
                        .titleLarge
                        ?.color,
                    fontSize: AppWidgetSize.fontSize14,
                    fontWeight: FontWeight.bold)
                : label.startsWith("R")
                    ? TextStyle(
                        color: rightSideAreaColor,
                        fontSize: AppWidgetSize.fontSize14,
                        fontWeight: FontWeight.bold)
                    : TextStyle(
                        color: leftSideAreaColor,
                        fontSize: AppWidgetSize.fontSize14,
                        fontWeight: FontWeight.bold),
          );

          canvas.rotate(-angle * i);

          textPainter.layout();

          textPainter.paint(canvas, Offset(-radius - 22, -radius));

          canvas.restore();
        }
      }

      canvas.rotate(angle);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(TechnicalPivotStrategyArcPainter oldDelegate) {
    return false;
  }
}
