import 'package:acml/src/constants/app_events.dart';
import 'package:flutter/material.dart';

import '../../../../../localization/app_localization.dart';
import '../../../../navigation/screen_routes.dart';
import '../../../../styles/app_widget_size.dart';
import '../../../../widgets/custom_text_widget.dart';
import '../../../../widgets/secure_input_widget.dart';
import '../../../base/base_screen.dart';
import '../../support.dart';

class CreatePinScreen extends BaseScreen {
  const CreatePinScreen({Key? key}) : super(key: key);

  @override
  CreatePinState createState() => CreatePinState();
}

class CreatePinState extends BaseScreenState<CreatePinScreen> {
  late AppLocalizations _appLocalizations;

  @override
  void initState() {
    super.initState();

    setCurrentScreenInFirebaseAnalytics(ScreenRoutes.setPinScreen);
  }

  @override
  Widget build(BuildContext context) {
    _appLocalizations = AppLocalizations.of(context)!;
    return Scaffold(
      bottomNavigationBar: const SupportAndCallBottom(),
      appBar: AppBar(
        centerTitle: false,
        elevation: 0.0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        automaticallyImplyLeading: false,
        title: backIconButton(onTap: () => Navigator.of(context).pop()),
      ),
      body: _buildBody(),
    );
  }

  FocusNode pinfocus = FocusNode();

  Widget _buildBody() {
    return SingleChildScrollView(
      child: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        height: AppWidgetSize.fullHeight(context),
        padding: EdgeInsets.all(AppWidgetSize.dimen_30),
        child: Wrap(
          children: [
            buildTitleSection(),
            inputFieldSection(),
            SizedBox(
              height: 40.w,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 8.h),
          child: CustomTextWidget(
            _appLocalizations.setPin,
            Theme.of(context).textTheme.displayLarge,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(bottom: AppWidgetSize.dimen_54),
          child: CustomTextWidget(
            _appLocalizations.setPinDescription,
            Theme.of(context)
                .textTheme
                .labelLarge!
                .copyWith(fontWeight: FontWeight.w400),
          ),
        ),
      ],
    );
  }

  Container inputFieldSection() {
    return Container(
      margin: EdgeInsets.only(top: 30.h),
      alignment: Alignment.center,
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(bottom: 30.w),
            child: CustomTextWidget(
              _appLocalizations.enterPin,
              Theme.of(context).primaryTextTheme.labelLarge!.copyWith(
                    fontWeight: FontWeight.w400,
                  ),
            ),
          ),
          SecureTextInputWidget(
            changeInput,
            focusNode: pinfocus,
            pincode: pincode,
            autoFocus: true,
          ),
        ],
      ),
    );
  }

  TextEditingController pincode = TextEditingController();

  Future<void> changeInput(dynamic data, {String? type}) async {
    if (data.length == 4) {
      sendEventToFirebaseAnalytics(
        AppEvents.createpin,
        ScreenRoutes.setPinScreen,
        'Set pin is done and will move to confrim pin screen',
      );
      await Future.delayed(const Duration(milliseconds: 500), (() {
        pushNavigation(
          ScreenRoutes.confirmPinScreen,
          arguments: {'pin': data},
        );
      }));
      pincode.clear();
      setState(() {});
      pinfocus.unfocus();
      Future.delayed(const Duration(milliseconds: 200), () {
        pinfocus.requestFocus();
      });
    }
  }
}
