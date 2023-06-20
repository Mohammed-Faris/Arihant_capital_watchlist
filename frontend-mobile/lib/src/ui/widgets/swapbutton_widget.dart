import 'package:acml/src/ui/screens/acml_app.dart';
import 'package:flutter/material.dart';

import '../../config/app_config.dart';
import '../../localization/app_localization.dart';
import '../styles/app_widget_size.dart';
import 'dropdown.dart';

class SwappingWidget {
  static drop({required ValueNotifier<bool> value, Function()? onTap}) {
    return Featureflag.csToggle
        ? ValueListenableBuilder(
            valueListenable: value,
            builder: (context, i, _) {
              return GestureDetector(
                onDoubleTap: () {
                  if (onTap != null) {
                    onTap();
                  }
                },
                child: Container(
                    height: 30.w,
                    width: 120.w,
                    padding: EdgeInsets.only(
                        bottom: AppWidgetSize.dimen_2, left: 5.w, top: 2.w),
                    // height: AppWidgetSize.dimen_24,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color:
                            Theme.of(navigatorKey.currentContext!).dividerColor,
                        width: 1.2,
                      ),
                      borderRadius:
                          BorderRadius.circular(AppWidgetSize.dimen_5),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: CustomDropdownButton(
                        value: value.value
                            ? AppLocalizations().consolidated
                            : AppLocalizations().standalone,
                        onChanged: (data) {
                          value.value = data != AppLocalizations().consolidated;
                          if (onTap != null) {
                            onTap();
                          }
                        },
                        dropdownColor: Theme.of(navigatorKey.currentContext!)
                            .scaffoldBackgroundColor,
                        icon: Icon(
                          Icons.keyboard_arrow_down_outlined,
                          color: Theme.of(navigatorKey.currentContext!)
                              .textTheme
                              .bodyLarge
                              ?.color,
                          size: 25.w,
                        ),
                        items: [
                          AppLocalizations().consolidated,
                          AppLocalizations().standalone,
                        ].map((item) {
                          return DropdownMenuItem(
                            value: item,
                            child: Text(
                              item,
                              style: Theme.of(navigatorKey.currentContext!)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                      fontWeight: FontWeight.w400,
                                      color: ((value.value &&
                                                  item ==
                                                      AppLocalizations()
                                                          .consolidated) ||
                                              (!value.value &&
                                                  item ==
                                                      AppLocalizations()
                                                          .standalone))
                                          ? Theme.of(
                                                  navigatorKey.currentContext!)
                                              .primaryColor
                                          : null),
                            ),
                          );
                        }).toList(),
                      ),
                    )),
              );
            },
          )
        : Container();
  }
}
