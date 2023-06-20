import 'package:acml/src/screen_util/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoaderWidget extends StatefulWidget {
  const LoaderWidget({Key? key}) : super(key: key);

  @override
  State<LoaderWidget> createState() => _LoaderWidgetState();
}

class _LoaderWidgetState extends State<LoaderWidget>
    with TickerProviderStateMixin {
  @override
  void initState() {
    ani = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    super.initState();
  }

  @override
  void dispose() {
    ani.dispose();
    super.dispose();
  }

  late AnimationController ani;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: BoxConstraints(minHeight: 100.h),
        alignment: Alignment.center,
        child: SpinKitThreeBounce(
          controller: ani,
          color: Theme.of(context).primaryColor,
          size: 18.0,
        ),
      ),
    );
  }
}
