import 'package:acml/src/screen_util/flutter_screenutil.dart';
import 'package:flutter/material.dart';

import '../../../../localization/app_localization.dart';
import '../../../styles/app_color.dart';
import '../../../widgets/custom_text_widget.dart';

enum PLType { realized, unrealized }

enum Options {
  intraday,
  delivery,
  buyValue,
  buyAvg,
  sellValue,
  sellAvg,
  prevCloseval,
  marketValue
}

class PlWidget extends StatelessWidget {
  const PlWidget({
    Key? key,
    required this.symbol,
    required this.companyName,
    this.value,
    this.chngPer,
    this.quantity,
    required this.plType,
    this.intradayVal,
    this.intradayChngPer,
    this.deliveryVal,
    this.deliveryChngPer,
    this.buyValue,
    this.buyAvg,
    this.sellValue,
    this.sellAvg,
    this.prevCloseVal,
    this.marketValue,
  }) : super(key: key);

  final String symbol;
  final String companyName;
  final String? value;
  final String? chngPer;
  final String? quantity;
  final PLType plType;
  final String? intradayVal;
  final String? intradayChngPer;
  final String? deliveryVal;
  final String? deliveryChngPer;
  final String? buyValue;
  final String? buyAvg;
  final String? sellValue;
  final String? sellAvg;
  final String? prevCloseVal;
  final String? marketValue;

  String getLabel(Options options) {
    switch (options) {
      case Options.intraday:
        return AppLocalizations().intraDay;
      case Options.delivery:
        return AppLocalizations().delivery;
      case Options.buyValue:
        return AppLocalizations().buyValue;
      case Options.buyAvg:
        return AppLocalizations().buyAvg;
      case Options.sellValue:
        return AppLocalizations().sellValue;
      case Options.sellAvg:
        return AppLocalizations().sellAvg;
      case Options.prevCloseval:
        return AppLocalizations().prevCloseval;
      case Options.marketValue:
        return AppLocalizations().marketValue;
      default:
        return "--";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomTextWidget(
                symbol,
                Theme.of(context)
                    .primaryTextTheme
                    .labelLarge!
                    .copyWith(fontWeight: FontWeight.w600),
              ),
              CustomTextWidget(
                  value ?? "--",
                  Theme.of(context).primaryTextTheme.labelLarge!.copyWith(
                      fontWeight: FontWeight.w600,
                      color: value != null && value!.contains("-")
                          ? AppColors.negativeColor
                          : AppColors().positiveColor))
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomTextWidget(
                  companyName,
                  Theme.of(context)
                      .textTheme
                      .labelSmall!
                      .copyWith(fontSize: 14)),
              CustomTextWidget(
                  chngPer == null ? "-" : "($chngPer%)",
                  Theme.of(context)
                      .textTheme
                      .labelSmall!
                      .copyWith(fontSize: 14))
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomTextWidget(
                  "${AppLocalizations().qty}: $quantity",
                  Theme.of(context)
                      .textTheme
                      .labelSmall!
                      .copyWith(fontSize: 14)),
              CustomTextWidget(
                  plType == PLType.realized
                      ? AppLocalizations().realizedPL
                      : AppLocalizations().unrealizedPL,
                  Theme.of(context)
                      .textTheme
                      .labelSmall!
                      .copyWith(fontSize: 14))
            ],
          ),
          const SizedBox(height: 15),
          GridView.count(
            primary: false,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            crossAxisCount: 2,
            childAspectRatio: 5.5,
            shrinkWrap: true,
            children: [
              if (intradayVal != null)
                _valueWidget(context, Options.intraday, intradayVal,
                    chngPer: intradayChngPer),
              if (deliveryVal != null)
                _valueWidget(context, Options.delivery, deliveryVal,
                    chngPer: deliveryChngPer),
              if (buyValue != null)
                _valueWidget(context, Options.buyValue, buyValue),
              if (buyAvg != null) _valueWidget(context, Options.buyAvg, buyAvg),
              if (sellValue != null)
                _valueWidget(context, Options.sellValue, sellValue),
              if (sellAvg != null)
                _valueWidget(context, Options.sellAvg, sellAvg),
              if (prevCloseVal != null)
                _valueWidget(context, Options.prevCloseval, prevCloseVal),
              if (marketValue != null)
                _valueWidget(context, Options.marketValue, marketValue),
            ],
          )
        ],
      ),
    );
  }

  Container _valueWidget(BuildContext context, Options options, String? val,
          {String? chngPer}) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        color: Theme.of(context).appBarTheme.backgroundColor,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CustomTextWidget(getLabel(options),
                Theme.of(context).textTheme.labelSmall!.copyWith(fontSize: 13)),
            if (options == Options.intraday || options == Options.delivery)
              RichText(
                  text: TextSpan(children: [
                TextSpan(
                    text: val ?? "-",
                    style: Theme.of(context)
                        .primaryTextTheme
                        .labelSmall!
                        .copyWith(
                            fontWeight: FontWeight.w500,
                            color: val != null && val.contains("-")
                                ? AppColors.negativeColor
                                : AppColors().positiveColor)),
                TextSpan(
                    text: chngPer == null ? " -" : " ($chngPer%)",
                    style: Theme.of(context)
                        .textTheme
                        .labelSmall!
                        .copyWith(fontSize: 13))
              ]))
            else
              CustomTextWidget(
                  val ?? "-",
                  Theme.of(context)
                      .primaryTextTheme
                      .labelSmall!
                      .copyWith(fontWeight: FontWeight.w500))
          ],
        ),
      );
}


//               PlWidget(
//                 symbol: "ARIHANTCAP",
//                 companyName: "Arihant Capital Market Ltd.",
//                 value: "6.32",
//                 chngPer: "0.54",
//                 quantity: "800",
//                 plType: PLType.realized,
//                 intradayVal: "706.15",
//                 intradayChngPer: "0.54",
//                 deliveryVal: "706.15",
//                 deliveryChngPer: "0.54",
//                 buyValue: "706.15",
//                 buyAvg: "1,2706.15",
//                 sellValue: "1,160.60",
//                 sellAvg: "1,160.60",
//                 prevCloseVal: "130",
//                 marketValue: "1,160.60",
//               );