import 'package:flutter/material.dart';

class ValueListenableWidget extends StatelessWidget {
  const ValueListenableWidget(
      {Key? key, required this.child, required this.value})
      : super(key: key);
  final Widget child;
  final ValueNotifier value;
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: value,
      builder: ((context, value, _) => child),
    );
  }
}
