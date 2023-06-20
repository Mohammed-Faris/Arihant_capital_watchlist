import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerWidget extends StatefulWidget {
  final double width;
  final double height;
  final Color baseColor;
  final Color highlightColor;
  const ShimmerWidget({
    Key? key,
    this.width = 100,
    this.height = 25,
    required this.baseColor,
    required this.highlightColor,
  }) : super(key: key);

  @override
  State<ShimmerWidget> createState() => _ShimmerWidgetState();
}

class _ShimmerWidgetState extends State<ShimmerWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: widget.baseColor,
      highlightColor: widget.highlightColor,
      child: Container(
        width: widget.width,
        height: widget.height,
        color: widget.baseColor,
      ),
    );
  }
}
