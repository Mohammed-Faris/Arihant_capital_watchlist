import 'package:flutter/material.dart';

class RefreshWidget extends StatelessWidget {
  final Function() onRefresh;
  final Widget child;
  const RefreshWidget({Key? key, required this.onRefresh, required this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      backgroundColor: Theme.of(context).primaryColor,
      color: const Color(0xFFFFFFFF),
      onRefresh: () async {
        onRefresh();
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: child,
    );
  }
}
