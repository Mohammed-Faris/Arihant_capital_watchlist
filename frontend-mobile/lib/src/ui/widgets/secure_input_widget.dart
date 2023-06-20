import 'dart:io';

import 'package:flutter/material.dart';
import 'package:smart_auth/smart_auth.dart';

import '../../constants/app_constants.dart';
import '../navigation/screen_routes.dart';
import '../styles/app_widget_size.dart';
import '../validator/input_validator.dart';
import 'flutter_pin_input/widget/src/pinput.dart';

// ignore: must_be_immutable
class SecureTextInputWidget extends StatefulWidget {
  final bool? visiblity;
  final bool? autoFocus;
  final int? length;
  final Function changeInput;
  final Color? borderColor;
  bool error;
  final FocusNode? focusNode;
  final bool errorAnimate;
  SecureTextInputWidget(
    this.changeInput, {
    Key? key,
    this.visiblity = false,
    this.length = 4,
    this.autoFocus = true,
    this.pincode,
    this.borderColor,
    this.focusNode,
    this.error = false,
    this.errorAnimate = false,
  }) : super(key: key);
  TextEditingController? pincode;
  @override
  SecureTextInputWidgetState createState() => SecureTextInputWidgetState();
}

class SecureTextInputWidgetState extends State<SecureTextInputWidget>
    with WidgetsBindingObserver {
  final TextEditingController pinCode = TextEditingController(text: '');
  String pinCodeText = '';
  final smartAuth = SmartAuth();

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    if (Platform.isAndroid) {
      getAppSignature();
    }

    super.initState();
  }

  void getAppSignature() async {
    final res = await smartAuth.getAppSignature();
    debugPrint('Signature: $res');
    smsRetriever();
  }

  void smsRetriever() async {
    final res = await smartAuth.getSmsCode();
    smsRetriever();
    if (res.codeFound) {
      widget.pincode?.text = (res.code ?? "");
      pinCode.text = res.code ?? "";
    } else {
      debugPrint('smsRetriever failed: $res');
    }
    debugPrint('smsRetriever: $res');
  }

  void clearValue() {
    pinCode.clear();
    setState(() {
      pinCodeText = '';
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        if (mounted) {
          if (ModalRoute.of(context)?.settings.name.toString() ==
                  ScreenRoutes.smartLoginScreen ||
              ModalRoute.of(context)?.settings.name.toString() ==
                  ScreenRoutes.setPinScreen ||
              ModalRoute.of(context)?.settings.name.toString() ==
                  ScreenRoutes.confirmPinScreen ||
              ModalRoute.of(context)?.settings.name.toString() ==
                  ScreenRoutes.confirmOtpScreen) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (widget.focusNode?.hasFocus ?? false) {
                widget.focusNode?.unfocus();
                Future.delayed(const Duration(milliseconds: 400), () {
                  widget.focusNode?.requestFocus();
                });
              }
            });
          }
        }
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.paused:
        break;
      case AppLifecycleState.detached:
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 20.w,
      height: 20.w,
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      textStyle: const TextStyle(fontSize: 0, fontWeight: FontWeight.w600),
      decoration: BoxDecoration(
        border: Border.all(
            color: widget.error
                ? Theme.of(context).colorScheme.errorContainer
                : Theme.of(context).primaryTextTheme.labelLarge!.color!),
        borderRadius: BorderRadius.circular(20.w),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(
          color: widget.error
              ? Theme.of(context).colorScheme.errorContainer
              : Theme.of(context).primaryTextTheme.labelLarge!.color!),
      borderRadius: BorderRadius.circular(20.w),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration?.copyWith(
        color: Theme.of(context).primaryTextTheme.labelLarge!.color!,
      ),
    );

    return SizedBox(
      height: AppWidgetSize.screenHeight(context) * 0.05,
      width: AppWidgetSize.screenWidth(context),
      child: Center(
        child: Pinput(
          showCursor: false,
          obscureText: false,
          toolbarEnabled: false,
          hapticFeedbackType: HapticFeedbackType.lightImpact,
          androidSmsAutofillMethod: AndroidSmsAutofillMethod.smsRetrieverApi,
          listenForMultipleSmsOnAndroid: true,
          submittedPinTheme: submittedPinTheme,
          focusedPinTheme: widget.pincode?.text.length == 4
              ? submittedPinTheme
              : focusedPinTheme,
          animationCurve: Curves.bounceIn,
          useNativeKeyboard: true,
          defaultPinTheme: defaultPinTheme,
          autofocus: widget.autoFocus ?? true,
          inputFormatters: InputValidator.numberRegEx,
          controller: widget.pincode ?? pinCode,
          pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
          keyboardType: TextInputType.number,
          focusNode: widget.focusNode,
          onChanged: (data) {
            if (pinCodeText != data) {
              final RegExp panRegPatten = RegExp(r'[0-9]$');
              final bool panPatternMatch = panRegPatten.hasMatch(data);
              if (data == '' || panPatternMatch) {
                setState(() {
                  widget.error = false;
                  pinCodeText = data;
                });
              }
            }
          },
          closeKeyboardWhenCompleted: false,
          onCompleted: (data) {
            Future.delayed(const Duration(milliseconds: 200), () {
              widget.changeInput(data, type: AppConstants.submitConstant);
            });
          },
        ),
      ),
    );
  }
}
