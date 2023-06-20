import 'package:flutter/material.dart';

import '../../styles/app_widget_size.dart';

typedef OnToggle = void Function(int index);

// ignore: must_be_immutable
class ToggleCircularTabMWidget extends StatefulWidget {
  final List<String>? labels;
  final List<int>? length;
  final double cornerRadius;
  final OnToggle? onToggle;
  int initialLabel;
  final double minWidth;
  final double height;
  final bool isDisabled;
  final TabController tabController;

  ToggleCircularTabMWidget({
    this.labels,
    this.length,
    this.onToggle,
    required Key key,
    this.cornerRadius = 8.0,
    this.initialLabel = 0,
    this.minWidth = 100,
    required this.height,
    this.isDisabled = false,
    required this.tabController,
  }) : super(key: key);

  @override
  ToggleCircularTabMWidgetState createState() =>
      ToggleCircularTabMWidgetState();
}

class ToggleCircularTabMWidgetState extends State<ToggleCircularTabMWidget> {
  late int current;
  @override
  void initState() {
    super.initState();
    current = widget.initialLabel;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: AppWidgetSize.screenWidth(context) - AppWidgetSize.dimen_60,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.cornerRadius),
        child: Container(
          height: widget.height,
          color: Theme.of(context).scaffoldBackgroundColor,
          child: TabBar(
            indicatorPadding: EdgeInsets.zero,
            padding: EdgeInsets.zero,
            indicatorWeight: 0,
            labelPadding: EdgeInsets.zero,
            controller: widget.tabController,
            indicator: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(widget.cornerRadius)),
            indicatorColor: Colors.transparent,
            tabs: List<Widget>.generate(
              widget.labels!.length,
              (int index) {
                return GestureDetector(
                  onTap: () {
                    if (!widget.isDisabled) {
                      _handleOnTap(index);
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: widget.tabController.index == index
                          ? Theme.of(context)
                              .primaryTextTheme
                              .displayLarge!
                              .color
                          : Theme.of(context).snackBarTheme.backgroundColor,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      widget.labels![index],
                      style: widget.tabController.index == index
                          ? Theme.of(context)
                              .primaryTextTheme
                              .headlineSmall!
                              .copyWith(
                                color: Theme.of(context).colorScheme.secondary,
                              )
                          : Theme.of(context)
                              .primaryTextTheme
                              .headlineSmall!
                              .copyWith(
                                color: Theme.of(context)
                                    .primaryTextTheme
                                    .displayLarge!
                                    .color,
                              ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void _handleOnTap(int index) async {
    setState(() => current = index);
    if (widget.onToggle != null) {
      widget.onToggle!(index);
      widget.initialLabel = current;
    }
  }
}
