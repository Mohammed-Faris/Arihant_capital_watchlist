import '../styles/app_widget_size.dart';
import 'package:flutter/material.dart';

import '../styles/app_images.dart';

class ReOrderableListViewTile extends StatefulWidget {
  final int? itemIndex;
  final String? title;
  final bool? showCloseIcon;
  final double? height;
  const ReOrderableListViewTile({
    Key? key,
    this.itemIndex,
    this.title,
    this.showCloseIcon,
    this.height,
  }) : super(key: key);

  @override
  State<ReOrderableListViewTile> createState() =>
      _ReOrderableListViewTileState();
}

class _ReOrderableListViewTileState extends State<ReOrderableListViewTile> {
  @override
  Widget build(BuildContext context) {
    return listItem(context, widget.itemIndex!, widget.height!, widget.title!,
        widget.showCloseIcon!);
  }
}

Widget listItem(BuildContext context, int index, double height, String title,
    bool showCloseIcon) {
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: AppWidgetSize.dimen_16),
    child: SizedBox(
      height: height,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          SizedBox(child: AppImages.dragDrop(context)),
          Container(
              margin: EdgeInsets.all(AppWidgetSize.dimen_10),
              child: Text(title)),
          showCloseIcon
              ? SizedBox(child: AppImages.cancelMarkets(context))
              : const SizedBox(
                  height: 0,
                  width: 0,
                )
        ],
      ),
    ),
  );
}
