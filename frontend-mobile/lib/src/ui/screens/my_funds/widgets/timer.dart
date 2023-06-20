import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../blocs/my_funds/other_upi/other_upi_bloc.dart';
import '../../../../constants/app_constants.dart';
import '../../../../localization/app_localization.dart';
import '../../../navigation/screen_routes.dart';
import '../../../styles/app_images.dart';
import '../../../styles/app_widget_size.dart';
import '../../../widgets/custom_text_widget.dart';
import '../../../widgets/gradient_button_widget.dart';
import '../../../widgets/rupee_symbol_widget.dart';
import '../../base/base_screen.dart';
import 'notification_info.dart';

class TimerwithLoaderArgs {
  TimerwithLoaderArgs();
}

class TimerwithLoader extends BaseScreen {
  final dynamic arguments;
  const TimerwithLoader({Key? key, this.arguments}) : super(key: key);

  @override
  State<TimerwithLoader> createState() => _TimerwithLoaderState();
}

class _TimerwithLoaderState extends BaseAuthScreenState<TimerwithLoader>
    with WidgetsBindingObserver {
  Timer? _timer;
  Timer? callApitimer;
  int _start = 600;
  bool isResultShown = false;
  @override
  void initState() {
    BlocProvider.of<OtherUPIBloc>(context)
        .stream
        .listen(otherUpiTimerLoaderBlocListerner);

    BlocProvider.of<OtherUPIBloc>(context)
        .add(UpiTransStatusEvent()..transID = widget.arguments['transID']);

    startTimer();
    super.initState();
  }

  Future<void> otherUpiTimerLoaderBlocListerner(OtherUPIState state) async {
    if (state is OtherUPITransStatusDoneState) {
      if (state.upiTransactionStatusModel!.status!
          .toLowerCase()
          .contains('success')) {
        isResultShown = true;
        if (callApitimer != null) {
          if (callApitimer!.isActive) {
            callApitimer?.cancel();
          }
        }

        showSuccessAcknowledgement(
            context: context,
            title: 'Payment Successful',
            msg: state.upiTransactionStatusModel!.reason!.isEmpty
                ? 'Transaction done successfully'
                : state.upiTransactionStatusModel!.reason ?? "",
            transID: state.upiTransactionStatusModel!.transId ?? "");
      } else if (state.upiTransactionStatusModel!.status!
          .toLowerCase()
          .contains('failure')) {
        if (callApitimer != null) {
          if (callApitimer!.isActive) {
            callApitimer?.cancel();
          }
        }
        isResultShown = true;
        _buildFailedMessage(
            state.upiTransactionStatusModel!.reason ?? "Something went Wrong");
      } else {
        isResultShown = false;

        if (callApitimer != null) {
          if (callApitimer!.isActive) {
            callApitimer?.cancel();
          }
        }

        callApitimer = Timer.periodic(const Duration(seconds: 5), (timer) {
          BlocProvider.of<OtherUPIBloc>(context).add(
              UpiTransStatusEvent()..transID = widget.arguments['transID']);
        });
      }
    } else if (state is OtherUPIErrorState) {
      if (state.isInvalidException) {
        handleError(state);
      } else {
        if (callApitimer != null) {
          if (callApitimer!.isActive) {
            callApitimer!.cancel();
          }
        }
        showToast(message: state.errorMsg, isError: true);
      }
    }
  }

  void startTimer() {
    const oneSec = Duration(seconds: 1);

    _timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_start == 0) {
          setState(() {
            timer.cancel();
          });

          if (callApitimer != null) {
            if (callApitimer!.isActive) {
              callApitimer!.cancel();
            }
          }
          isResultShown = true;
          _buildFailedMessage("Session Expired");
        } else {
          setState(() {
            _start--;
          });
        }
      },
    );
  }

  void _buildFailedMessage(String message) {
    return showFailedAcknowledgement(
      context: context,
      title: 'Payment Failed',
      msg: message,
      mapdata: {
        'amount': widget.arguments['amount'],
        'vpa': widget.arguments['vpa'],
        'transID': widget.arguments['transID']
      },
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        if (isResultShown == false) {
          if (callApitimer!.isActive == false) {
            callApitimer = Timer.periodic(const Duration(seconds: 5), (timer) {
              BlocProvider.of<OtherUPIBloc>(context).add(
                  UpiTransStatusEvent()..transID = widget.arguments['transID']);
            });
          } else {}
        }
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.paused:
        if (callApitimer != null) {
          if (callApitimer!.isActive) {
            callApitimer!.cancel();
          }
        }
        break;
      case AppLifecycleState.detached:
        break;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    callApitimer?.cancel();
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  int noOfBack = 0;
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (noOfBack == 0) {
          showToast(message: "Press again to Exit", isError: true);
          noOfBack++;
        } else {
          popNavigation();
        }
        return Future.delayed(const Duration(seconds: 0), () => false);
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          iconTheme: Theme.of(context).iconTheme.copyWith(
              color: Theme.of(context).textTheme.headlineSmall?.color),
        ),
        body: SafeArea(
          child: SizedBox(
            height: AppWidgetSize.screenHeight(context),
            width: AppWidgetSize.screenWidth(context),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildIndicatorContainer(),
                Padding(
                  padding: EdgeInsets.only(
                      top: AppWidgetSize.screenHeight(context) * 0.1),
                  child: const NotificationInfo(
                    info:
                        'Note: Please do not press back button or close screen until payment is complete',
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: AppWidgetSize.dimen_50),
                  child: Text(
                      "This page will automatically close in ${Duration(seconds: _start).toString().substring(2, 7)} minutes.",
                      style: Theme.of(context).textTheme.titleLarge),
                ),
                Padding(
                  padding: EdgeInsets.only(top: AppWidgetSize.dimen_50),
                  child: Center(
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                          trackHeight: 10,
                          thumbColor: Colors.transparent,
                          thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 0.0)),
                      child: Slider(
                        value: _start.toDouble(),
                        max: 600,
                        min: 0,
                        activeColor: Theme.of(context).primaryColor,
                        onChanged: (double value) {},
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIndicatorContainer() {
    return SizedBox(
      height: AppWidgetSize.dimen_220,
      width: AppWidgetSize.fullWidth(context),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _buildIndiatorWidget(),
          _buildIndicatorTextWidget(),
          _buildIndiatorIcons()
        ],
      ),
    );
  }

  Widget _buildIndiatorIcons() {
    return Padding(
      padding: EdgeInsets.only(left: AppWidgetSize.dimen_20),
      child: Column(
        children: [
          AppImages.otherupiLogo(context),
          SizedBox(
            height: AppWidgetSize.dimen_20,
          ),
          AppImages.otherupiLogo_dup(context),
        ],
      ),
    );
  }

  Widget _buildIndicatorTextWidget() {
    return Padding(
      padding: EdgeInsets.only(top: AppWidgetSize.dimen_25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: AppWidgetSize.dimen_10),
            child: SizedBox(
              width: AppWidgetSize.halfWidth(context),
              child: _buildIndicatorText('Go to the UPI linked Bank/UPI'),
            ),
          ),
          SizedBox(
            height: AppWidgetSize.dimen_70,
          ),
          Padding(
            padding: EdgeInsets.only(left: AppWidgetSize.dimen_10),
            child: SizedBox(
              width: AppWidgetSize.halfWidth(context) + AppWidgetSize.dimen_10,
              child: _buildIndicatorText(
                  'Check pending request and approve payment by entering UPI PIN'),
            ),
          ),
        ],
      ),
    );
  }

  Text _buildIndicatorText(String value) {
    return Text(
      value,
      style: Theme.of(context)
          .primaryTextTheme
          .labelSmall!
          .copyWith(fontWeight: FontWeight.w600),
    );
  }

  Widget _buildIndiatorWidget() {
    return Padding(
      padding: EdgeInsets.only(left: AppWidgetSize.dimen_20),
      child: SizedBox(
        height: AppWidgetSize.dimen_150,
        width: AppWidgetSize.dimen_20,
        child:
            Column(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          Container(
            height: AppWidgetSize.dimen_25,
            width: AppWidgetSize.dimen_25,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryTextTheme.labelLarge!.color!,
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(context).primaryTextTheme.labelLarge!.color!,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: AppWidgetSize.dimen_8),
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(
                      color:
                          Theme.of(context).primaryTextTheme.labelLarge!.color!,
                      width: 2.0,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Container(
            height: AppWidgetSize.dimen_25,
            width: AppWidgetSize.dimen_25,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryTextTheme.labelLarge!.color!,
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(context).primaryTextTheme.labelLarge!.color!,
              ),
            ),
          ),
        ]),
      ),
    );
  }

  void showSuccessAcknowledgement(
      {required BuildContext context,
      required String title,
      required String msg,
      required String transID}) {
    showModalBottomSheet(
      backgroundColor: Theme.of(context).bottomSheetTheme.backgroundColor,
      context: context,
      enableDrag: false,
      isDismissible: true,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (_, StateSetter updateState) {
            return DraggableScrollableSheet(
              expand: false,
              maxChildSize: 1,
              initialChildSize: 1,
              builder: (_, ScrollController scrollController) {
                return Stack(
                  children: [
                    _buildTopWidget(context, title, msg, transID),
                    _buildButtonBottomWidget(context, true)
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  SingleChildScrollView _buildTopWidget(
      BuildContext context, String title, String msg, String transID) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          _buildUpperWidget(context, title, msg, transID),
          _buildFundsView(context),
        ],
      ),
    );
  }

  Padding _buildUpperWidget(
      BuildContext context, String title, String msg, String transID) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppWidgetSize.dimen_30,
        right: AppWidgetSize.dimen_30,
        top: AppWidgetSize.dimen_80,
        bottom: AppWidgetSize.dimen_40,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            AppImages.successImage(context),
            Padding(
              padding: EdgeInsets.only(
                top: AppWidgetSize.dimen_30,
                bottom: AppWidgetSize.dimen_30,
              ),
              child: CustomTextWidget(
                title,
                Theme.of(context).primaryTextTheme.titleSmall!.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            /*Padding(
              padding: EdgeInsets.only(
                top: AppWidgetSize.dimen_20,
                bottom: AppWidgetSize.dimen_30,
              ),
              child: CustomTextWidget(
                msg,
                Theme.of(context).primaryTextTheme.overline,
                textAlign: TextAlign.center,
              ),
            ),*/
            Padding(
              padding: EdgeInsets.only(
                top: AppWidgetSize.dimen_20,
                bottom: AppWidgetSize.dimen_30,
              ),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  children: [
                    TextSpan(
                        text: 'Hurray!',
                        style: Theme.of(context).textTheme.headlineSmall),
                    TextSpan(
                      text: ' \u{20B9}',
                      style:
                          Theme.of(context).textTheme.headlineSmall!.copyWith(
                                fontFamily: AppConstants.interFont,
                              ),
                    ),
                    TextSpan(
                      text:
                          '${widget.arguments['amount']} has been added succesfully to your account. And its transaction reference number is $transID',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Column _buildFundsView(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(
            bottom: AppWidgetSize.dimen_40,
          ),
          child: GestureDetector(
            onTap: () {
              pushNavigation(ScreenRoutes.fundhistoryScreen);
            },
            child: CustomTextWidget(
                AppLocalizations.of(context)!.viewFundsHistory,
                Theme.of(context).primaryTextTheme.headlineMedium),
          ),
        ),
      ],
    );
  }

  Padding _buildButtonBottomWidget(BuildContext context, bool value) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppWidgetSize.dimen_20,
        right: AppWidgetSize.dimen_20,
      ),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildButtonCallBack(context, 'My Funds', 'success'),
            _buildButtonCallBack(context, 'Start Investing', 'success')
          ],
        ),
      ),
    );
  }

  Widget _buildButtonCallBack(
      BuildContext context, String keyvalue, String source) {
    return gradientButtonWidget(
      onTap: () {
        if (source.contains('success')) {
        } else if (source.contains('fail')) {}

        if (keyvalue == 'Start Investing') {
          pushAndRemoveUntilNavigation(ScreenRoutes.homeScreen,
              arguments: {'pageName': ScreenRoutes.watchlistScreen});
        } else {
          pushAndRemoveUntilNavigation(ScreenRoutes.homeScreen,
              arguments: {'pageName': ScreenRoutes.myfundsScreen});
        }
      },
      width: AppWidgetSize.fullWidth(context) / 2.5,
      key: Key(keyvalue),
      context: context,
      title: keyvalue,
      isGradient: true,
    );
  }

  void showFailedAcknowledgement({
    required BuildContext context,
    required String title,
    required String msg,
    required Map<String, String> mapdata,
  }) {
    showModalBottomSheet(
      backgroundColor: Theme.of(context).bottomSheetTheme.backgroundColor,
      context: context,
      enableDrag: false,
      isDismissible: true,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (_, StateSetter updateState) {
            return DraggableScrollableSheet(
              expand: false,
              maxChildSize: 1,
              initialChildSize: 1,
              builder: (_, ScrollController scrollController) {
                return Scaffold(
                  body: Stack(
                    children: [
                      _buildTopFailWidget(context, title, msg, mapdata),
                      _buildButtonBottomFailWidget(context)
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildTopFailWidget(BuildContext context, String title, String msg,
      Map<String, String> data) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          _buildUpperTopWidget(context, title, msg),
          _buildFailDataWidget(data),
        ],
      ),
    );
  }

  Padding _buildButtonBottomFailWidget(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppWidgetSize.dimen_20,
        right: AppWidgetSize.dimen_20,
      ),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: _buildButtonCallBack(context, "My Funds", 'fail'),
      ),
    );
  }

  Widget _buildUpperTopWidget(BuildContext context, String title, String msg) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppWidgetSize.dimen_30,
        right: AppWidgetSize.dimen_30,
        top: AppWidgetSize.dimen_80,
        bottom: AppWidgetSize.dimen_10,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            AppImages.paymentFailed(
              context,
            ),
            Padding(
              padding: EdgeInsets.only(
                top: AppWidgetSize.dimen_30,
                bottom: AppWidgetSize.dimen_30,
              ),
              child: CustomTextWidget(
                title,
                Theme.of(context).primaryTextTheme.titleSmall!.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            if (msg.isNotEmpty)
              CustomTextWidget(
                msg,
                Theme.of(context).primaryTextTheme.labelSmall,
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFailDataWidget(Map<String, String> datavalue) {
    return Column(
      children: [
        _buildAmountDataWidget(datavalue['amount']!),
        _buildVPADataWidget(datavalue['vpa']!),
        _buildTransactionIDDataWidget(datavalue['transID']!),
      ],
    );
  }

  Widget _getLableWithRupeeSymbol(
    String value,
    TextStyle? rupeeStyle,
    TextStyle? textStyle,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        getRupeeSymbol(
          context,
          rupeeStyle!,
        ),
        CustomTextWidget(
          value,
          textStyle,
        ),
      ],
    );
  }

  Widget _buildAmountDataWidget(String amount) {
    return _buildRowData('Amount', amount, false);
  }

  Widget _buildVPADataWidget(String vpa) {
    return _buildRowData('vpa', vpa, false);
  }

  Widget _buildTransactionIDDataWidget(String transID) {
    return _buildRowData('Transaction ID', transID, true);
  }

  Widget _buildRowData(String key, String value, bool iscopy) {
    return Padding(
      padding: EdgeInsets.only(
        top: AppWidgetSize.dimen_15,
        left: AppWidgetSize.dimen_20,
        right: AppWidgetSize.dimen_20,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(key, style: Theme.of(context).textTheme.titleLarge!),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (key.toLowerCase().contains('amount'))
                _getLableWithRupeeSymbol(
                  value,
                  Theme.of(context).textTheme.titleLarge!.copyWith(
                      fontFamily: AppConstants.interFont,
                      fontWeight: FontWeight.w500),
                  Theme.of(context).textTheme.titleLarge!.copyWith(
                      fontFamily: AppConstants.interFont,
                      fontWeight: FontWeight.w500),
                )
              else
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      fontFamily: AppConstants.interFont,
                      fontWeight: FontWeight.w500),
                ),
              if (iscopy)
                Padding(
                  padding: EdgeInsets.only(
                    left: AppWidgetSize.dimen_3,
                  ),
                  child: GestureDetector(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: value));
                      showToast(
                        message: "Copied",
                        context: context,
                      );
                    },
                    child: AppImages.copyIcon(context,
                        color: Theme.of(context).textTheme.labelSmall!.color,
                        isColor: true),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
