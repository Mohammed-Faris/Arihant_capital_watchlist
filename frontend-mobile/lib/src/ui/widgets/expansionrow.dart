import 'package:flutter/material.dart';

import '../styles/app_images.dart';
import '../styles/app_widget_size.dart';
import 'custom_text_widget.dart';

class ExpansionRow extends StatefulWidget {
  final String title;
  final bool initiallExpanded;
  final Widget child;
  final TextStyle? titleStyle;
  final Widget footer;
  final Function()? onInfoTap;
  const ExpansionRow(
      {Key? key,
      required this.title,
      this.onInfoTap,
      required this.initiallExpanded,
      required this.child,
      required this.footer,
      this.titleStyle})
      : super(key: key);

  @override
  State<ExpansionRow> createState() => _ExpansionRowState();
}

class _ExpansionRowState extends State<ExpansionRow> {
  bool isExpandedByTap = false;
  bool expansionValue = false;
  @override
  Widget build(BuildContext context) {
    final GlobalKey expansionTileKey = GlobalKey();
    return Padding(
      padding: EdgeInsets.only(
        bottom: AppWidgetSize.dimen_5,
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
            dividerColor: Colors.transparent,
            dropdownMenuTheme: Theme.of(context).dropdownMenuTheme,
            scaffoldBackgroundColor: Theme.of(context).scaffoldBackgroundColor,
            primaryColor: Theme.of(context).primaryColor),
        child: ExpansionTile(
          onExpansionChanged: (value) {
            isExpandedByTap = true;
            expansionValue = value;
            if (value) {
              scrollToSelectedContent(expansionTileKey: expansionTileKey);
            }
          },
          tilePadding: const EdgeInsets.only(
            left: 0,
            bottom: 0,
          ),
          key: expansionTileKey,
          collapsedIconColor: Theme.of(context).primaryIconTheme.color,
          title: _buildHeaderWidget(),
          iconColor: Theme.of(context).primaryIconTheme.color,
          initiallyExpanded: isExpandedByTap == false
              ? widget.initiallExpanded
              : expansionValue,
          expandedCrossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            _buildDivider(),
            widget.child,
            widget.footer,
          ],
        ),
      ),
    );
  }

  void scrollToSelectedContent({GlobalKey? expansionTileKey}) {
    final keyContext = expansionTileKey?.currentContext;
    if (keyContext != null) {
      Future.delayed(const Duration(milliseconds: 400)).then((value) {
        Scrollable.ensureVisible(keyContext,
            duration: const Duration(milliseconds: 200));
      });
    }
  }

  Widget _buildHeaderWidget() {
    return Row(
      children: [
        CustomTextWidget(
          widget.title,
          widget.titleStyle ?? Theme.of(context).primaryTextTheme.titleSmall,
        ),
        Padding(
          padding: EdgeInsets.only(
            top: AppWidgetSize.dimen_6,
            left: AppWidgetSize.dimen_5,
          ),
          child: widget.onInfoTap == null
              ? const SizedBox.shrink()
              : GestureDetector(
                  onTap: () {
                    if (widget.onInfoTap != null) {
                      widget.onInfoTap!();
                    }
                  },
                  child: AppImages.informationIcon(
                    context,
                    color: Theme.of(context).primaryIconTheme.color,
                    isColor: true,
                    width: AppWidgetSize.dimen_22,
                    height: AppWidgetSize.dimen_22,
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: EdgeInsets.only(
        top: AppWidgetSize.dimen_5,
      ),
      child: Divider(
        thickness: AppWidgetSize.dimen_1,
        color: Theme.of(context).dividerColor,
      ),
    );
  }
}
