import 'package:flutter/material.dart';

import '../styles/app_widget_size.dart';

typedef OnToggle = void Function(int index);

// ignore: must_be_immutable
class ToggleCircularTabsWidget extends StatefulWidget {
  final List<String>? labels;
  final List<int>? length;
  final double cornerRadius;
  final OnToggle? onToggle;
  int initialLabel;
  final double minWidth;
  final double height;
  final bool isDisabled;
  final TabController tabController;
  ToggleCircularTabsWidget({
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
  ToggleCircularTabsWidgetState createState() =>
      ToggleCircularTabsWidgetState();
}

class ToggleCircularTabsWidgetState extends State<ToggleCircularTabsWidget> {
  late int current;
  @override
  void initState() {
    super.initState();
    current = widget.initialLabel;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).primaryColor),
        borderRadius: BorderRadius.circular(widget.cornerRadius.w),
        color: Theme.of(context).scaffoldBackgroundColor,
      ),
      padding: EdgeInsets.all(2.w),
      alignment: Alignment.center,
      height: AppWidgetSize.dimen_40,
      child: TabBar(
        controller: widget.tabController,
        padding: const EdgeInsets.all(0),
        labelPadding: EdgeInsets.all(2.w),
        indicatorColor: Colors.green,
        indicatorPadding: const EdgeInsets.all(0),
        labelColor: Colors.white,
        indicatorWeight: 0,
        labelStyle: Theme.of(context).primaryTextTheme.headlineSmall,
        unselectedLabelStyle: Theme.of(context).primaryTextTheme.headlineSmall!,
        unselectedLabelColor: Theme.of(context).primaryColor,
        indicator: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(widget.cornerRadius)),
        indicatorSize: TabBarIndicatorSize.tab,
        tabs: List<Widget>.generate(
          widget.labels!.length,
          (int index) {
            return Tab(
              child: Center(
                  child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  widget.labels![index],
                ),
              )),
            );
          },
        ),
      ),
    );
  }
}
