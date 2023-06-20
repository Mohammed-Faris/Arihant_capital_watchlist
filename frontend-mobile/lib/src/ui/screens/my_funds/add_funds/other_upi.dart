// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../blocs/my_funds/other_upi/other_upi_bloc.dart';
import '../../../../data/store/app_storage.dart';
import '../../../../localization/app_localization.dart';
import '../../../navigation/screen_routes.dart';
import '../../../styles/app_color.dart';
import '../../../styles/app_images.dart';
import '../../../styles/app_widget_size.dart';
import '../../../widgets/custom_text_widget.dart';
import '../../base/base_screen.dart';

class OtherUPI extends BaseScreen {
  final dynamic arguments;
  const OtherUPI({Key? key, this.arguments}) : super(key: key);

  @override
  OtherUPIStates createState() => OtherUPIStates();
}

class OtherUPIStates extends BaseAuthScreenState<OtherUPI>
    with WidgetsBindingObserver {
  final TextEditingController otherUpiController =
      TextEditingController(text: '');

  @override
  void initState() {
    fetchUpi();
    super.initState();
    BlocProvider.of<OtherUPIBloc>(context).stream.listen(otherUPIBlocListner);
  }

  Future<void> otherUPIBlocListner(OtherUPIState state) async {
    if (state is OtherUPIVerifyVPADoneState) {
      stopLoader();
      _sendUPIInitProcessRequest();
    } else if (state is OtherUPIinitProcessDoneState) {
      showToast(message: state.upiInitProcessModel!.msg, isError: false);

      pushNavigation(ScreenRoutes.timerPage, arguments: {
        "transID": BlocProvider.of<OtherUPIBloc>(context)
            .otherUPIinitProcessDoneState
            .upiInitProcessModel!
            .transID,
        "amount": widget.arguments['amount'],
        "vpa": otherUpiController.text,
      });
    } else if (state is OtherUPIErrorState) {
      if (state.isInvalidException) {
        handleError(state);
      } else {
        stopLoader();
        showToast(message: state.errorMsg, isError: true);
      }
    } else if (state is OtherUPIProgressState) {
      startLoader();
    } else if (state is! OtherUPIProgressState) {
      stopLoader();
    }
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  void _sendUPIInitProcessRequest() {
    BlocProvider.of<OtherUPIBloc>(context).add(UpiInitProcessEvent()
      ..paychannel = widget.arguments['paychannel']
      ..vpa = otherUpiController.text
      ..amount = widget.arguments['amount']
      ..accountnumberlist = widget.arguments['bankaccountnumberlist']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          Padding(
            padding: EdgeInsets.only(
                top: AppWidgetSize.dimen_20, left: AppWidgetSize.dimen_20),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios),
                  onPressed: () {
                    popNavigation();
                  },
                ),
                Padding(
                  padding: EdgeInsets.only(left: AppWidgetSize.dimen_5),
                  child: CustomTextWidget(
                      "Other UPI",
                      Theme.of(context)
                          .textTheme
                          .headlineSmall!
                          .copyWith(fontWeight: FontWeight.w600)),
                )
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: AppWidgetSize.dimen_30,
                vertical: AppWidgetSize.dimen_30),
            child: TextFormField(
              enableInteractiveSelection: true,
              toolbarOptions: const ToolbarOptions(
                copy: false,
                cut: false,
                paste: false,
                selectAll: false,
              ),
              autocorrect: false,
              enabled: true,
              autofocus: true,
              onChanged: (String text) {
                setState(() {});
              },
              style: Theme.of(context).primaryTextTheme.labelLarge!.copyWith(
                    fontWeight: FontWeight.w400,
                  ),
              textInputAction: TextInputAction.done,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              keyboardType: TextInputType.text,
              controller: otherUpiController,
              decoration: InputDecoration(
                suffixIcon: otherUpiController.text != ""
                    ? GestureDetector(
                        onTap: () {
                          otherUpiController.clear();
                          setState(() {});
                        },
                        child: Padding(
                            padding: EdgeInsets.all(AppWidgetSize.dimen_10),
                            child: AppImages.close(
                              context,
                              color: Theme.of(context).primaryIconTheme.color,
                              isColor: true,
                            )),
                      )
                    : null,
                contentPadding: EdgeInsets.only(
                  left: AppWidgetSize.dimen_15,
                  top: AppWidgetSize.dimen_12,
                  bottom: AppWidgetSize.dimen_12,
                  right: AppWidgetSize.dimen_10,
                ),
                labelText: "Enter UPI ID",
                labelStyle:
                    Theme.of(context).primaryTextTheme.labelSmall!.copyWith(),
                counterText: '',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppWidgetSize.dimen_5),
                  borderSide: BorderSide(color: Theme.of(context).dividerColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Theme.of(context).dividerColor,
                      width: AppWidgetSize.dimen_1),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Theme.of(context).dividerColor,
                      width: AppWidgetSize.dimen_1),
                ),
              ),
              maxLength: 50,
            ),
          ),
        ]),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: buildFooterWidget(),
    );
  }

  Widget buildFooterWidget() {
    return Padding(
      padding: EdgeInsets.only(
        top: AppWidgetSize.dimen_20,
      ),
      child: SizedBox(
        height: AppWidgetSize.dimen_54,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _getBottomButtonWidget(
              AppLocalizations().cancel,
              AppColors().positiveColor,
              false,
              true,
            ),
            SizedBox(width: AppWidgetSize.dimen_32),
            _getBottomButtonWidget(
              AppLocalizations().confirm,
              AppColors().positiveColor,
              true,
              false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _getBottomButtonWidget(
    String header,
    Color color,
    bool isGradient,
    bool isHollowColored,
  ) {
    return Opacity(
      opacity: header == AppLocalizations().confirm
          ? otherUpiController.text == ""
              ? 0.3
              : 1
          : 1,
      child: GestureDetector(
        onTap: () async {
          if (header == AppLocalizations().confirm) {
            var accDetails = await AppStorage().getData("userLoginDetailsKey");

            await AppStorage().setData("otherUpiDetail", {
              "accName": accDetails["accName"],
              "otherUpi": otherUpiController.text
            });
            if (!mounted) return;

            BlocProvider.of<OtherUPIBloc>(context).add(UpiCheckVPAEvent()
              ..paychannel = widget.arguments['paychannel']
              ..vpa = otherUpiController.text);
          } else {
            Navigator.pop(context);
          }
        },
        child: Container(
          alignment: Alignment.center,
          width: AppWidgetSize.dimen_130,
          height: AppWidgetSize.fullWidth(context) / 6,
          // padding: EdgeInsets.all(AppWidgetSize.dimen_10),
          decoration: isGradient
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(AppWidgetSize.dimen_25),
                  gradient: LinearGradient(
                    stops: const [0.0, 1.0],
                    begin: FractionalOffset.topLeft,
                    end: FractionalOffset.topRight,
                    colors: <Color>[
                      Theme.of(context).colorScheme.onBackground,
                      AppColors().positiveColor,
                    ],
                  ),
                )
              : BoxDecoration(
                  border: Border.all(
                    color: isHollowColored
                        ? AppColors.negativeColor
                        : AppColors().positiveColor,
                    width: 1.5,
                  ),
                  color: isHollowColored
                      ? Colors.transparent
                      : AppColors().positiveColor,
                  borderRadius: BorderRadius.circular(AppWidgetSize.dimen_30),
                ),
          child: Text(
            header,
            textAlign: TextAlign.center,
            style: Theme.of(context).primaryTextTheme.displaySmall!.copyWith(
                color: isHollowColored
                    ? AppColors.negativeColor
                    : Theme.of(context).colorScheme.secondary),
          ),
        ),
      ),
    );
  }

  Future<void> fetchUpi() async {
    var data = await AppStorage().getData("otherUpiDetail");
    var accDetails = await AppStorage().getData("userLoginDetailsKey");
    if (data != null && accDetails != null) {
      if (data["accName"] == accDetails["accName"]) {
        otherUpiController.value = TextEditingValue(
          text: data["otherUpi"],
          selection: TextSelection.collapsed(offset: data["otherUpi"].length),
        );
      }
    }
  }
}
