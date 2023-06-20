import 'package:flutter/material.dart';

import 'technical_pivot_strategy_arcpainter.dart';
import 'technical_pivot_strategy_needlepainter.dart';
import 'technical_pivot_strategy_widget_test_keyconstants.dart';
import 'technicals_pivot_strategy_helper.dart';

class TechnicalPivotStrategyChart extends StatefulWidget {
  final ThemeData themeData;
  final List<Color> colormapObj;
  final dynamic list;
  final dynamic valuesList;
  final String valueToBeHighlighted;

  // ignore: use_key_in_widget_constructors
  const TechnicalPivotStrategyChart({
    Key? key,
    required this.themeData,
    required this.colormapObj,
    required this.list,
    required this.valuesList,
    required this.valueToBeHighlighted,
  });

  @override
  TechnicalPivotStrategyChartState createState() =>
      TechnicalPivotStrategyChartState();
}

class TechnicalPivotStrategyChartState
    extends State<TechnicalPivotStrategyChart> {
  TechnicalPivotStrategyChartState();

  final TechnicalsPivotStrategyHelper _technicalsPivotStrategyHelper =
      TechnicalsPivotStrategyHelper();

  @override
  Widget build(BuildContext context) {
    _technicalsPivotStrategyHelper.setListValues(
        widget.valuesList, widget.valueToBeHighlighted);
    return Center(
      key:
          const Key(TechnicalPivotStrategyWidgetTestKeyConstants.mainCenterKey),
      child: LayoutBuilder(
        key: const Key(
            TechnicalPivotStrategyWidgetTestKeyConstants.layoutCenterChildKey),
        builder: (BuildContext context, BoxConstraints constraints) {
          if (constraints.maxWidth >= 20.0) {
            return SizedBox(
              key: const Key(TechnicalPivotStrategyWidgetTestKeyConstants
                  .containerLayoutChildKey),
              height: constraints.maxWidth,
              width: constraints.maxWidth,
              //color: Colors.yellow,
              child: Stack(
                key: const Key(TechnicalPivotStrategyWidgetTestKeyConstants
                    .stackContainerChildKey),
                fit: StackFit.expand,
                children: <Widget>[
                  Container(
                    key: const Key(TechnicalPivotStrategyWidgetTestKeyConstants
                        .arcContainerStackChildKey),
                    child: CustomPaint(
                      key: const Key(
                          TechnicalPivotStrategyWidgetTestKeyConstants
                              .arcCustomerPaintContainerChildKey),
                      foregroundPainter: TechnicalPivotStrategyArcPainter(
                          pivotPointsList: widget.list,
                          themeData: widget.themeData,
                          leftSideAreaColor: (widget.colormapObj.isNotEmpty &&
                                  widget.colormapObj.length == 2)
                              ? widget.colormapObj[0]
                              : Theme.of(context).primaryColor,
                          rightSideAreaColor: (widget.colormapObj.isNotEmpty &&
                                  widget.colormapObj.length == 2)
                              ? widget.colormapObj[1]
                              : Theme.of(context).colorScheme.error,
                          width: 12.0),
                    ),
                  ),
                  Center(
                    key: const Key(TechnicalPivotStrategyWidgetTestKeyConstants
                        .needleCenterStackChildKey),
                    child: SizedBox(
                      key: const Key(
                          TechnicalPivotStrategyWidgetTestKeyConstants
                              .needleContainerCenterChildKey),
                      height: getSizeForcontainer(constraints),
                      width: getSizeForcontainer(constraints),
                      child: CustomPaint(
                        key: const Key(
                            TechnicalPivotStrategyWidgetTestKeyConstants
                                .needleCustomerPaintContainerChildKey),
                        painter: TechnicalPivotStrategyNeedlePainter(
                          value: _technicalsPivotStrategyHelper
                              .getValueToBePointed(),
                          color: Theme.of(context).primaryColor,
                          innercirclecolor:
                              widget.themeData.colorScheme.background,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return Container();
        },
      ),
    );
  }

  double getSizeForcontainer(BoxConstraints constraints) {
    if (constraints.maxWidth == 0) {
      return 0.0;
    }

    return constraints.maxWidth / 2; //+ constraints.maxWidth / 4 ;
  }
}
