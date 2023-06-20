// ignore_for_file: constant_identifier_names

library draggable_fab;

import 'dart:math';
import 'package:flutter/material.dart';

/// Draggable FAB widget which is always aligned to
/// the edge of the screen - be it left,top, right,bottom
class DraggableFab extends StatefulWidget {
  final Widget child;
  final Offset? initPosition;
  final double securityBottom;
  final Size childSize;

  const DraggableFab(
      {Key? key,
      required this.child,
      this.initPosition,
      this.securityBottom = 0,
      required this.childSize})
      : super(key: key);

  @override
  DraggableFabState createState() => DraggableFabState();
}

class DraggableFabState extends State<DraggableFab> {
  late Size _widgetSize;
  double? _left, _top;
  double _screenWidth = 0.0, _screenHeight = 0.0;
  double? _screenWidthMid, _screenHeightMid;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance
        .addPostFrameCallback((_) => _getWidgetSize(context));
  }

  void _getWidgetSize(BuildContext context) {
    _widgetSize = context.size!;

    _left = widget.childSize.width;
    _top = widget.childSize.height;
    _calculatePosition(Offset(widget.childSize.width, widget.childSize.height));
  }

  final GlobalKey stackKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Stack(key: stackKey, children: [
      Positioned(
        left: _left,
        top: _top,
        child: Draggable(
          feedback: widget.child,
          onDragEnd: _handleDragEnded,
          childWhenDragging: const SizedBox(
            width: 0.0,
            height: 0.0,
          ),
          child: widget.child,
        ),
      )
    ]);
  }

  void _handleDragEnded(DraggableDetails dragDetails) {
    final parentPos = stackKey.globalPaintBounds;
    if (parentPos == null) return;
    _left = dragDetails.offset.dx - parentPos.left; // 11.
    _top = dragDetails.offset.dy - parentPos.top;
    _calculatePosition(Offset(_left!, _top!));
  }

  void _calculatePosition(Offset targetOffset) {
    _screenWidth = widget.childSize.width;
    _screenHeight = widget.childSize.height;
    _screenWidthMid = _screenWidth / 2;
    _screenHeightMid = _screenHeight / 2;
    double dx = targetOffset.dx;

    double dy = targetOffset.dy;
    switch (_getAnchor(targetOffset)) {
      case Anchor.LEFT_FIRST:
        _left = _widgetSize.width / 2;
        _top = max(_widgetSize.height / 2, dy);

        break;
      case Anchor.TOP_FIRST:
        _left = max(_widgetSize.width / 2, dx.abs());
        _top = _widgetSize.height / 2;
        break;
      case Anchor.RIGHT_SECOND:
        _left = _screenWidth - _widgetSize.width;
        _top = max(_widgetSize.height, dy);
        break;
      case Anchor.TOP_SECOND:
        _left = min(_screenWidth - _widgetSize.width, dx);
        _top = _widgetSize.height / 2;
        break;
      case Anchor.LEFT_THIRD:
        _left = _widgetSize.width / 2;
        _top =
            min(_screenHeight - _widgetSize.height - widget.securityBottom, dy);
        break;
      case Anchor.BOTTOM_THIRD:
        _left = _widgetSize.width / 2;
        _top = _screenHeight - _widgetSize.height - widget.securityBottom;
        break;
      case Anchor.RIGHT_FOURTH:
        _left = _screenWidth - _widgetSize.width;
        _top =
            min(_screenHeight - _widgetSize.height - widget.securityBottom, dy);
        break;
      case Anchor.BOTTOM_FOURTH:
        _left = _screenWidth - _widgetSize.width;
        _top = _screenHeight - _widgetSize.height - widget.securityBottom;
        break;
    }
    setState(() {});
  }

  /// Computes the appropriate anchor screen edge for the widget
  Anchor _getAnchor(Offset position) {
    if (position.dx < _screenWidthMid! && position.dy < _screenHeightMid!) {
      return position.dx < position.dy ? Anchor.LEFT_FIRST : Anchor.TOP_FIRST;
    } else if (position.dx >= _screenWidthMid! &&
        position.dy < _screenHeightMid!) {
      return _screenWidth - position.dx < position.dy
          ? Anchor.RIGHT_SECOND
          : Anchor.TOP_SECOND;
    } else if (position.dx < _screenWidthMid! &&
        position.dy >= _screenHeightMid!) {
      return position.dx < _screenHeight - position.dy
          ? Anchor.LEFT_THIRD
          : Anchor.BOTTOM_THIRD;
    } else {
      return _screenWidth - position.dx < _screenHeight - position.dy
          ? Anchor.RIGHT_FOURTH
          : Anchor.BOTTOM_FOURTH;
    }
  }
}

/// #######################################
/// #       |          #        |         #
/// #    TOP_FIRST     #  TOP_SECOND      #
/// # - LEFT_FIRST     #  RIGHT_SECOND -  #
/// #######################################
/// # - LEFT_THIRD     #   RIGHT_FOURTH - #
/// #  BOTTOM_THIRD    #   BOTTOM_FOURTH  #
/// #     |            #       |          #
/// #######################################
enum Anchor {
  LEFT_FIRST,
  TOP_FIRST,
  RIGHT_SECOND,
  TOP_SECOND,
  LEFT_THIRD,
  BOTTOM_THIRD,
  RIGHT_FOURTH,
  BOTTOM_FOURTH
}

extension GlobalKeyExtension on GlobalKey {
  Rect? get globalPaintBounds {
    final renderObject = currentContext?.findRenderObject();
    var translation = renderObject?.getTransformTo(null).getTranslation();
    if (translation != null && renderObject?.paintBounds != null) {
      return renderObject!.paintBounds
          .shift(Offset(translation.x, translation.y));
    } else {
      return null;
    }
  }
}
