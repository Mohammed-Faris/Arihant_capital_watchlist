import 'package:acml/src/ui/widgets/custom_text_widget.dart';
import 'package:flutter/material.dart';

import '../../data/store/app_utils.dart';
import '../styles/app_widget_size.dart';

Widget horizontalListView({
  required var values,
  required int selectedIndex,
  bool isRectShape = false,
  bool isEnabled = true,
  required Function callback,
  Function? onLongPress,
  bool? shirinkWrap,
  required Color highlighterColor,
  required BuildContext context,
  double vertical = 4,
  double fontSize = 16,
  double height = 36,
}) {
  final List<GlobalObjectKey<FormState>> formKeyList = List.generate(
      values.length, (index) => GlobalObjectKey<FormState>(index));
  return Container(
    margin:
        EdgeInsets.only(top: vertical, bottom: vertical, left: 10.w, right: 0),
    height: height.w,
    width: AppWidgetSize.fullWidth(context) - 80.w,
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: values.length,
      shrinkWrap: shirinkWrap ?? true,
      itemBuilder: (context, index) {
        String value = values[index];
        final double valueLabelWidth = value == ''
            ? 5
            : value.textSize(
                value,
                Theme.of(context).textTheme.headlineSmall!.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: fontSize.w,
                    ),
              );
        return GestureDetector(
          //  key: formKeyList[index],
          onTap: () {
            if (selectedIndex != index) {
              if (isEnabled) callback(value, index);
            }

            scrollToSelectedContent(expansionTileKey: formKeyList[index]);
          },
          onLongPress: () {
            if (onLongPress != null) {
              if (isEnabled) onLongPress(value);
            }
          },
          child: Container(
            margin: EdgeInsets.only(
                right: index + 1 == formKeyList.length ? 0 : 20.w),
            width: valueLabelWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: AppWidgetSize.dimen_3,
                    ),
                    child: Text(
                      value,
                      style:
                          Theme.of(context).textTheme.headlineSmall!.copyWith(
                                color: isEnabled
                                    ? index == selectedIndex
                                        ? highlighterColor
                                        : Theme.of(context).colorScheme.primary
                                    : Theme.of(context).disabledColor,
                                fontSize: fontSize.w,
                              ),
                      key: Key(value),
                    ),
                  ),
                ),
                Container(
                  width: valueLabelWidth,
                  height: AppWidgetSize.dimen_3,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: index == selectedIndex
                        ? highlighterColor
                        : Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(
                      AppWidgetSize.dimen_20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}

void scrollToSelectedContent({GlobalKey? expansionTileKey}) {
  final keyContext = expansionTileKey?.currentContext;
  if (keyContext != null) {
    Future.delayed(const Duration(milliseconds: 100)).then((value) {
      Scrollable.ensureVisible(keyContext,
          duration: const Duration(milliseconds: 200));
    });
  }
}

Widget horizontalListViewCenter({
  required var values,
  required int selectedIndex,
  bool isRectShape = false,
  bool isEnabled = true,
  required Function callback,
  Function? onLongPress,
  bool? shirinkWrap,
  required Color highlighterColor,
  required BuildContext context,
  double vertical = 4,
  double fontSize = 16,
  double height = 36,
}) {
  final List<GlobalObjectKey<FormState>> formKeyList = List.generate(
      values.length, (index) => GlobalObjectKey<FormState>(index));
  return Center(
    child: Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(color: Theme.of(context).dividerColor))),
      margin:
          EdgeInsets.only(top: vertical, bottom: vertical, left: 0.w, right: 0),
      height: height.w,
      width: AppWidgetSize.fullWidth(context) - 80.w,
      child: Center(
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: values.length,
          itemExtent: AppWidgetSize.screenWidth(context) / 4,
          shrinkWrap: shirinkWrap ?? true,
          itemBuilder: (context, index) {
            String value = values[index];
            final double valueLabelWidth = value == ''
                ? 5
                : value.textSize(
                    value,
                    Theme.of(context).textTheme.headlineSmall!.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: fontSize.w,
                        ),
                  );
            return GestureDetector(
              //  key: formKeyList[index],
              onTap: () {
                if (selectedIndex != index) {
                  if (isEnabled) callback(value, index);
                }

                scrollToSelectedContent(expansionTileKey: formKeyList[index]);
              },
              onLongPress: () {
                if (onLongPress != null) {
                  if (isEnabled) onLongPress(value);
                }
              },
              child: Container(
                margin: EdgeInsets.only(
                    right: index + 1 == formKeyList.length ? 0 : 15.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: EdgeInsets.only(
                          top: AppWidgetSize.dimen_5,
                          bottom: 7,
                        ),
                        child: CustomTextWidget(
                          value,
                          Theme.of(context).textTheme.headlineSmall!.copyWith(
                                color: isEnabled
                                    ? index == selectedIndex
                                        ? highlighterColor
                                        : Theme.of(context).colorScheme.primary
                                    : Theme.of(context).disabledColor,
                                fontSize: fontSize.w,
                              ),
                          key: Key(value),
                        ),
                      ),
                    ),
                    Container(
                      width: valueLabelWidth + 30.w,
                      height: AppWidgetSize.dimen_3,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: index == selectedIndex
                            ? highlighterColor
                            : Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(
                          AppWidgetSize.dimen_20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    ),
  );
}
