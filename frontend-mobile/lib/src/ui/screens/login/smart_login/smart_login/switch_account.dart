import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../constants/app_constants.dart';
import '../../../../../constants/keys/login_keys.dart';
import '../../../../../constants/storage_constants.dart';
import '../../../../../data/store/app_storage.dart';
import '../../../../../data/store/app_store.dart';
import '../../../../../data/store/app_utils.dart';
import '../../../../../localization/app_localization.dart';
import '../../../../navigation/screen_routes.dart';
import '../../../../styles/app_images.dart';
import '../../../../styles/app_widget_size.dart';
import '../../../../widgets/custom_text_widget.dart';
import '../../../acml_app.dart';
import '../../../base/base_screen.dart';
import '../../login_screen.dart';

class SwitchAccount {
  static Future<void> switchAccount(BuildContext context,
      {Function()? callback}) async {
    List<dynamic> users = await AppUtils().getAlluserDetails();
    // ignore: use_build_context_synchronously
    showModalBottomSheet(
      context: context,
      // ignore: use_build_context_synchronously
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: false,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppWidgetSize.dimen_20),
      ),
      isScrollControlled: true,
      builder: (BuildContext bct) {
        return buildbody(users, context, callback);
      },
    );
  }

  static Widget buildbody(List<dynamic> lastThreeUserLoginDetails,
      BuildContext context, Function()? callback) {
    return StatefulBuilder(builder: (_, StateSetter updateState) {
      return Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).primaryColor,
            width: 1.5,
          ),
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.all(
            Radius.circular(AppWidgetSize.dimen_20),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: EdgeInsets.symmetric(horizontal: AppWidgetSize.dimen_5),
              child: SafeArea(
                child: Container(
                  padding: EdgeInsets.only(
                    top: AppWidgetSize.dimen_20,
                  ),
                  child: Wrap(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                          left: AppWidgetSize.dimen_30,
                          right: AppWidgetSize.dimen_30,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    CustomTextWidget(
                                      AppLocalizations().switchAccountTitle,
                                      Theme.of(context).textTheme.displayMedium,
                                    ),
                                    FutureBuilder<dynamic>(
                                        future: getStatus(),
                                        builder: (context, snapshot) {
                                          if (snapshot.data == false) {
                                            return GestureDetector(
                                              onTap: () async {
                                                await AppStorage().setData(
                                                    AppConstants
                                                        .showSwitchAccNote,
                                                    true);
                                                updateState(() {});
                                              },
                                              child: SizedBox(
                                                child: Container(
                                                    alignment:
                                                        Alignment.centerRight,
                                                    padding: EdgeInsets.only(
                                                        top: 5.w),
                                                    width: 25.w,
                                                    height: 35.w,
                                                    child: AppImages
                                                        .informationIcon(
                                                            context,
                                                            color: Theme.of(
                                                                    context)
                                                                .primaryIconTheme
                                                                .color,
                                                            isColor: true,
                                                            height: 25.w,
                                                            width: 25.w)),
                                              ),
                                            );
                                          } else {
                                            return Container();
                                          }
                                        }),
                                  ],
                                ),
                                GestureDetector(
                                  onTap: () => Navigator.of(context).pop(),
                                  child: AppImages.closeIcon(
                                    context,
                                    color: Theme.of(context)
                                        .primaryIconTheme
                                        .color,
                                    isColor: true,
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                top: AppWidgetSize.dimen_10,
                                bottom: AppWidgetSize.dimen_30,
                              ),
                              child: CustomTextWidget(
                                AppLocalizations().switchAccountDescription,
                                Theme.of(context)
                                    .textTheme
                                    .labelLarge!
                                    .copyWith(fontWeight: FontWeight.w400),
                              ),
                            ),
                            if (lastThreeUserLoginDetails.isNotEmpty)
                              Padding(
                                padding: EdgeInsets.only(
                                    bottom: AppWidgetSize.dimen_20),
                                child: SingleChildScrollView(
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: lastThreeUserLoginDetails.length,
                                    itemBuilder:
                                        (BuildContext context, dynamic index) {
                                      return buildSwitchAccountRow(
                                          lastThreeUserLoginDetails[index],
                                          index + 1 ==
                                              lastThreeUserLoginDetails.length,
                                          context,
                                          callback);
                                    },
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      FutureBuilder<dynamic>(
                          future: getStatus(),
                          builder: (context, snapshot) {
                            if (snapshot.data ?? true) {
                              return _buildFooterDescriptionWidget(
                                  context, updateState);
                            } else {
                              return Container();
                            }
                          }),
                      Padding(
                        padding: EdgeInsets.only(bottom: 20.w, top: 10.w),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).pushNamedAndRemoveUntil(
                                ScreenRoutes.loginScreen,
                                (Route<dynamic> route) => false);
                            if (callback != null) {
                              callback();
                            }
                          },
                          child: Center(
                            child: Container(
                              height: AppWidgetSize.dimen_54,
                              width: AppWidgetSize.dimen_300,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Theme.of(context).primaryColor,
                                  width: 1.5,
                                ),
                                borderRadius: BorderRadius.circular(
                                    AppWidgetSize.dimen_30),
                              ),
                              child: Center(
                                child: CustomTextWidget(
                                  AppLocalizations().newAccount,
                                  Theme.of(context)
                                      .primaryTextTheme
                                      .displaySmall!
                                      .copyWith(
                                        fontWeight: FontWeight.w400,
                                      ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  static Future<dynamic> getStatus() async =>
      await AppStorage().getData(AppConstants.showSwitchAccNote);

  static Widget _buildFooterDescriptionWidget(
      BuildContext context, updateState) {
    return SafeArea(
      child: Container(
        margin: EdgeInsets.only(bottom: 10.w),
        color: Theme.of(context).snackBarTheme.backgroundColor,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppWidgetSize.dimen_10,
            vertical: AppWidgetSize.dimen_10,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                  padding: EdgeInsets.only(
                      left: AppWidgetSize.dimen_5,
                      right: AppWidgetSize.dimen_10),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          AppImages.bankNotificationBadgelogo(context,
                              isColor: true, width: 25.w),
                          Text(
                            AppLocalizations().note,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                    decoration: TextDecoration.underline,
                                    fontSize: 13.5.w,
                                    fontWeight: FontWeight.w500),
                            textAlign: TextAlign.justify,
                          ),
                        ],
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                              left: AppWidgetSize.dimen_5,
                              right: AppWidgetSize.dimen_10),
                          child: Text(
                            "👨‍👩‍👦‍👦 Now accessing family accounts became more simple!",
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontSize: 14.5.w, height: 1.w),
                            textAlign: TextAlign.justify,
                          ),
                        ),
                      ),
                      Container(
                        alignment: Alignment.topRight,
                        width: AppWidgetSize.dimen_25,
                        height: 40.w,
                        padding: EdgeInsets.only(left: AppWidgetSize.dimen_8),
                        child: GestureDetector(
                          onTap: (() async => {
                                await AppStorage().setData(
                                    AppConstants.showSwitchAccNote, false),
                                updateState(() {})
                              }),
                          child: AppImages.close(context,
                              color: Theme.of(context).primaryIconTheme.color,
                              isColor: true),
                        ),
                      )
                    ],
                  )),
              Padding(
                padding: EdgeInsets.only(
                    left: AppWidgetSize.dimen_5, right: AppWidgetSize.dimen_10),
                child: Text(
                  "\nYou can add upto 5 accounts and switch between them with ease.\nTip: You can always replace the first logged-in account to access more accounts",
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontSize: 14.5.w, height: 1.w),
                  textAlign: TextAlign.justify,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static format(DateTime date) {
    var suffix = "th";
    var digit = date.day % 10;
    if ((digit > 0 && digit < 4) && (date.day < 11 || date.day > 13)) {
      suffix = ["st", "nd", "rd"][digit - 1];
    }
    return DateFormat("dd'$suffix' MMM, yyyy hh:mm a").format(date);
  }

  static Widget buildSwitchAccountRow(dynamic userDetail, bool isLast,
      BuildContext context, Function()? callback) {
    return GestureDetector(
      onTap: () async {
        Navigator.of(context).pop();

        if (userDetail[accNameConstants] != AppStore().getAccountName() ||
            callback == null) {
          AppStore().setAccountName(userDetail["accName"]);
          AppStore().setUserName(userDetail["userName"]);
          await AppStorage().setData("userLoginDetailsKey", userDetail);
          if (userDetail['pinStatus'] == 'setPin') {
            await AppUtils().removeCurrentUser(uid: userDetail['uid']);
            // ignore: use_build_context_synchronously
            showToast(
                message: AppLocalizations().loginAndSetNewPin,
                isError: true,
                context: context);
            navigatorKey.currentState?.pushReplacementNamed(
                ScreenRoutes.loginScreen,
                arguments: LoginScreenArgs(clientId: userDetail[uidConstants]));
          } else {
            if (userDetail[isForgotPinConstants] != null &&
                userDetail[isForgotPinConstants] == 'true') {
              AppUtils().saveLastThreeUserData(
                  data: userDetail, key: isForgotPinConstants, value: 'false');
              AppUtils()
                  .saveDataInAppStorage(userIdKey, userDetail[uidConstants]);
              navigatorKey.currentState?.pushReplacementNamed(
                ScreenRoutes.smartLoginScreen,
                arguments: {
                  'loginPin': true,
                },
              );
            } else {
              AppUtils().saveLastThreeUserData(data: userDetail);
              AppUtils()
                  .saveDataInAppStorage(userIdKey, userDetail[uidConstants]);
              navigatorKey.currentState?.pushReplacementNamed(
                ScreenRoutes.smartLoginScreen,
                arguments: {
                  'loginPin': true,
                },
              );
            }
          }
          if (callback != null) {
            callback();
          }
        }
      },
      child: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        constraints: BoxConstraints(
                            maxWidth: AppWidgetSize.screenWidth(context) * 0.7),
                        child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Row(
                              children: [
                                Row(
                                  children: [
                                    CustomTextWidget(
                                        userDetail["accName"] ?? "--",
                                        Theme.of(context)
                                            .textTheme
                                            .headlineMedium!
                                            .copyWith(
                                                fontWeight: FontWeight.w600)),
                                  ],
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                    left: AppWidgetSize.dimen_10,
                                    top: AppWidgetSize.dimen_3,
                                  ),
                                  child: CustomTextWidget(
                                      '(${userDetail["uid"]})',
                                      Theme.of(context)
                                          .primaryTextTheme
                                          .labelSmall),
                                ),
                              ],
                            ))),
                    Padding(
                      padding: EdgeInsets.only(
                        top: AppWidgetSize.dimen_5,
                        bottom: AppWidgetSize.dimen_5,
                      ),
                      child: CustomTextWidget(
                          '${AppLocalizations().loggedOn} ${format(DateFormat('dd/MM/yyyy hh:mm:ss').parse('${userDetail["lastLoginTime"]}'))}',
                          Theme.of(context).primaryTextTheme.labelSmall),
                    ),
                  ],
                ),
                if (userDetail[accNameConstants] == AppStore().getAccountName())
                  SizedBox(
                    child: AppImages.greenTickIcon(
                      context,
                    ),
                  )
              ],
            ),
            if (!isLast)
              Padding(
                padding: EdgeInsets.only(
                  bottom: AppWidgetSize.dimen_5,
                ),
                child: Divider(
                  color: Theme.of(context).dividerColor,
                  thickness: 1,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
