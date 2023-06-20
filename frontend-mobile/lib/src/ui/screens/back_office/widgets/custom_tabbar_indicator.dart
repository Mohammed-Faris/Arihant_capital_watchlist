import 'package:flutter/material.dart';

enum IndicatorSize {
  tiny,
  normal,
  full,
}

class CustomIndicator extends Decoration {
  final BoxPainter _painter;

  CustomIndicator({
    required double indicatorHeight,
    required Color indicatorColor,
    required IndicatorSize indicatorSize,
  }) : _painter = _MD2Painter(indicatorColor, indicatorHeight, indicatorSize);

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) => _painter;
}

class _MD2Painter extends BoxPainter {
  final double indicatorHeight;
  final Paint _paint;
  final IndicatorSize indicatorSize;

  _MD2Painter(Color indicatorColor, this.indicatorHeight, this.indicatorSize)
      : _paint = Paint()
          ..color = indicatorColor
          ..style = PaintingStyle.fill;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    assert(configuration.size != null);

    Rect rect;
    if (indicatorSize == IndicatorSize.full) {
      rect = Offset(
            offset.dx,
            configuration.size!.height - indicatorHeight,
          ) &
          Size(configuration.size!.width, indicatorHeight);
    } else if (indicatorSize == IndicatorSize.tiny) {
      rect = Offset(
            offset.dx + configuration.size!.width / 2 - 8,
            configuration.size!.height - indicatorHeight,
          ) &
          Size(16, indicatorHeight);
    } else {
      rect = Offset(
            offset.dx + 6,
            configuration.size!.height - indicatorHeight,
          ) &
          Size(configuration.size!.width - 12, indicatorHeight);
    }

    canvas.drawRRect(
      RRect.fromRectAndCorners(
        rect,
        topRight: const Radius.circular(8),
        topLeft: const Radius.circular(8),
      ),
      _paint,
    );
  }
}
