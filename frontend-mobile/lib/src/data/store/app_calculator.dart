// ignore_for_file: depend_on_referenced_packages

import 'dart:developer';

import 'package:collection/collection.dart';

import '../../config/app_config.dart';
import '../../models/common/symbols_model.dart';
import '../../models/config/config_model.dart';
import '../../models/orders/order_book.dart';
import '../../models/positions/positions_model.dart';
import 'app_utils.dart';

class ACMCalci {
  static String holdingsTotalOneDayReturn(List<Symbols> holdings) {
    double value = holdings.fold(0, (double previousValue, Symbols element) {
      if (element.oneDayPnL != null &&
          element.oneDayPnL!.isNotEmpty &&
          AppUtils().doubleValue(element.avgPrice!) >= 0) {
        return previousValue + AppUtils().doubleValue(element.oneDayPnL);
      }
      return previousValue + 0.0;
    });

    return AppUtils().commaFmt(AppUtils().decimalValue(value));
  }

  static String holdingdtotalOverallPnlPercent(List<Symbols> holdings) {
    double invested = holdings.fold(0, (double previousValue, Symbols element) {
      if (element.invested != null &&
          element.invested!.isNotEmpty &&
          AppUtils().doubleValue(element.avgPrice!) > 0) {
        return previousValue + AppUtils().doubleValue(element.invested);
      }
      return previousValue + 0.0;
    });

    double current = holdings.fold(0, (double previousValue, Symbols element) {
      if (element.mktValue != null &&
          element.mktValue!.isNotEmpty &&
          AppUtils().doubleValue(element.avgPrice!) > 0) {
        return previousValue + AppUtils().doubleValue(element.mktValue);
      }
      return previousValue + 0.0;
    });
    double value = ((current - invested) / invested) * 100;
    return AppUtils()
        .commaFmt(AppUtils().decimalValue(value.isNaN ? "0.00" : value));
  }

  static String totalInvestedHoldings(List<Symbols> holdings) {
    double value = holdings.fold(0, (double previousValue, Symbols element) {
      if (element.invested != null && element.invested!.isNotEmpty) {
        return previousValue + AppUtils().doubleValue(element.invested);
      }
      return previousValue + 0.0;
    });

    return AppUtils().commaFmt(AppUtils().decimalValue(value));
  }

  static String holdingsOverallCurrentValue(List<Symbols> holdings) {
    double value = holdings.fold(0, (double previousValue, Symbols element) {
      if (element.oneDayPnL != null &&
          element.oneDayPnL!.isNotEmpty &&
          AppUtils().doubleValue(element.avgPrice!) >= 0) {
        return previousValue +
            (AppUtils().doubleValue(element.ltp) *
                AppUtils().doubleValue(element.qty));
      }
      return previousValue + 0.0;
    });

    return AppUtils().commaFmt(AppUtils().decimalValue(value));
  }

  static void logInfo(String logName, dynamic msg) {
    log('\x1B[34m$logName $msg\x1B[0m');
  }

  static String positionAvgPrice(
    Positions positions,
  ) {
    if (positions.isOneDay) {
      positions.cfBuyQty = "0";
      positions.cfSellQty = "0";
      positions.prevPos = "0";
      positions.buyQty = (AppUtils().intValue(positions.dayBuyQty)).toString();
      positions.sellQty =
          (AppUtils().intValue(positions.daySellQty)).toString();
      positions.buyAvgPrice = positions.dayBuyAvgPrice;
      positions.sellAvgPrice = positions.daySellAvgPrice;

      positions.netQty = (AppUtils().intValue(positions.currPos)).toString();
    }
    // num netbuyAvg = ((positions.dayBuyAvgPrice.exdouble() *
    //             positions.dayBuyQty.exdouble()) +
    //         positions.cfBuyAvgPrice.exdouble() *
    //             positions.cfBuyQty.exdouble()) /
    //     (positions.cfBuyQty.exdouble() + positions.dayBuyQty.exdouble());
    // num netSellAvg = ((positions.daySellAvgPrice.exdouble() *
    //             positions.daySellQty.exdouble()) +
    //         positions.cfSellAvgPrice.exdouble() *
    //             positions.cfSellQty.exdouble()) /
    //     (positions.cfSellQty.exdouble() + positions.daySellQty.exdouble());
    num avgPrice = (((positions.dayBuyAvgPrice.exdouble() *
                    positions.dayBuyQty.exdouble()) +
                positions.cfBuyAvgPrice.exdouble() *
                    positions.cfBuyQty.exdouble()) -
            (((positions.daySellAvgPrice.exdouble() *
                    positions.daySellQty.exdouble()) +
                positions.cfSellAvgPrice.exdouble() *
                    positions.cfSellQty.exdouble()))) /
        ((positions.cfBuyQty.exdouble() + positions.dayBuyQty.exdouble()) -
            (positions.cfSellQty.exdouble() + positions.daySellQty.exdouble()));

    return AppUtils().commaFmt(
      AppUtils().decimalValue(
        AppUtils().isValueNAN(avgPrice),
        // positions.netQty.exdouble() >= 0 ? netbuyAvg : netSellAvg),
        decimalPoint: AppUtils().getDecimalpoint(positions.sym!.exc!),
      ),
    );
  }

  static String holdingChangePercent(Symbols holdings) {
    final double calculatedvalue = ((AppUtils().doubleValue(holdings.ltp) -
                AppUtils().doubleValue(holdings.close)) /
            AppUtils().doubleValue(holdings.close)) *
        100;

    return AppUtils().commaFmt(
      AppUtils().decimalValue(AppUtils().isValueNAN(calculatedvalue),
          decimalPoint: AppUtils().getDecimalpoint(holdings.sym!.exc!)),
    );
  }

  static String holdingInvestedValue(Symbols holdings) {
    final double calculatedvalue = AppUtils().doubleValue(holdings.avgPrice) *
        AppUtils().doubleValue(holdings.qty);

    return AppUtils().commaFmt(
      AppUtils().decimalValue(AppUtils().isValueNAN(calculatedvalue),
          decimalPoint: AppUtils().getDecimalpoint(holdings.sym!.exc!)),
    );
  }

  static String holdingMktValue(Symbols holdings) {
    final double calculatedvalue = AppUtils().doubleValue(holdings.ltp) *
        AppUtils().doubleValue(holdings.qty);

    return AppUtils().commaFmt(
      AppUtils().decimalValue(AppUtils().isValueNAN(calculatedvalue),
          decimalPoint: AppUtils().getDecimalpoint(holdings.sym!.exc!)),
    );
  }

  static String holdingMktValueChange(Symbols holdings) {
    final double calculatedvalue = AppUtils().doubleValue(holdings.mktValue) -
        AppUtils().doubleValue(holdings.invested);

    return AppUtils().commaFmt(
      AppUtils().decimalValue(AppUtils().isValueNAN(calculatedvalue),
          decimalPoint: AppUtils().getDecimalpoint(holdings.sym!.exc!)),
    );
  }

  static String holdingOverallPnl(Symbols holdings) {
    holdings.isBond = AppUtils().doubleValue(holdings.avgPrice) == 0;
    final double calculatedvalue =
        AppUtils().doubleValue(holdings.avgPrice) == 0
            ? 0
            : (AppUtils().doubleValue(holdings.ltp) -
                    AppUtils().doubleValue(holdings.avgPrice)) *
                AppUtils().doubleValue(holdings.qty);

    return AppUtils().commaFmt(
      AppUtils().decimalValue(
          AppUtils().isValueNAN(calculatedvalue == 0 ? 0.00 : calculatedvalue),
          decimalPoint: AppUtils().getDecimalpoint(holdings.sym!.exc!)),
    );
  }

  static String holdingOverallPnlPercent(Symbols holdings) {
    final double calculatedvalue =
        (AppUtils().doubleValue(holdings.overallPnL) /
            AppUtils().doubleValue(holdings.invested) *
            100);
    return AppUtils().commaFmt(
      AppUtils().decimalValue(AppUtils().isValueNAN(calculatedvalue),
          decimalPoint: AppUtils().getDecimalpoint(holdings.sym!.exc!)),
    );
  }

  static String holdingOnedayPnl(Symbols holdings) {
    final double calculatedvalue = isMarketStarted(holdings)
        ? ((AppUtils().doubleValue(holdings.ltp) -
                AppUtils().doubleValue(holdings.close)) *
            AppUtils().intValue(holdings.qty))
        : 0;
    return AppUtils().commaFmt(
      AppUtils().decimalValue(
          AppUtils().isValueNAN(calculatedvalue == 0 ? 0.00 : calculatedvalue),
          decimalPoint: AppUtils().getDecimalpoint(holdings.sym!.exc!)),
    );
  }

  static String holdingOneDayPnlPercent(Symbols holdings) {
    final double calculatedvalue = AppUtils().doubleValue(holdings.qty) == 0
        ? 0.00
        : (((AppUtils().doubleValue(holdings.ltp) -
                    (AppUtils().doubleValue(holdings.close))) /
                (AppUtils().doubleValue(holdings.close))) *
            100);
    return AppUtils().commaFmt(
      AppUtils().decimalValue(AppUtils().isValueNAN(calculatedvalue),
          decimalPoint: AppUtils().getDecimalpoint(holdings.sym!.exc!)),
    );
  }

  static String holdingTotalOneDayReturnPercent(List<Symbols> holdings) {
    double invested = holdings.fold(0, (double previousValue, Symbols element) {
      if (element.close != null &&
          element.close!.isNotEmpty &&
          AppUtils().doubleValue(element.avgPrice!) > 0) {
        return previousValue +
            (AppUtils().doubleValue(element.close) *
                AppUtils().doubleValue(element.qty));
      }
      return previousValue + 0.0;
    });

    double pnl = holdings.fold(0, (double previousValue, Symbols element) {
      if (element.oneDayPnL != null &&
          element.oneDayPnL!.isNotEmpty &&
          AppUtils().doubleValue(element.avgPrice!) > 0) {
        return previousValue + AppUtils().doubleValue(element.oneDayPnL);
      }
      return previousValue + 0.0;
    });
    double value = ((pnl) / invested) * 100;
    return AppUtils()
        .commaFmt(AppUtils().decimalValue(value.isNaN ? "0.00" : value));
  }

  static String holdingsTotalOverallReturn(List<Symbols> holdings) {
    double value = holdings.fold(0, (double previousValue, Symbols element) {
      if (element.overallPnL != null &&
          element.overallPnL!.isNotEmpty &&
          AppUtils().doubleValue(element.avgPrice) > 0) {
        return previousValue + AppUtils().doubleValue(element.overallPnL);
      }
      return previousValue + 0.0;
    });

    return AppUtils().commaFmt(AppUtils().decimalValue(value));
  }

  static String oneDayPnlPosition(Positions positions) {
    num todayqtyPnl =
        ((positions.ltp.exdouble() - positions.dayBuyAvgPrice.exdouble()) *
                positions.dayBuyQty.exdouble()) +
            ((positions.daySellAvgPrice.exdouble() - positions.ltp.exdouble()) *
                positions.daySellQty.exdouble());
    // Today Qty's One day Pnl = ( ( LTP - BuyAvgPrice ) * ( BuyQty ) + ( SellAvgPrice - LTP ) * ( SellQty ) ) * Multiplier
    num cfDaypnl = ((positions.ltp.exdouble() - positions.close.exdouble()) *
        (positions.cfBuyQty.exdouble() - positions.cfSellQty.exdouble()));
    // CF Qty's One day Pnl = ( ( LTP - Close ) * (CfBuyQty - CfSellQty)

    num todayPnl = isMarketStarted(positions) ? (todayqtyPnl + cfDaypnl) : 0;
    // Total Today's Pnl = CarryForwarded Qty's One day Pnl + Today Qty's One day Pnl

    return AppUtils().commaFmt(
      AppUtils()
          .isValueNAN(todayPnl.toDouble())
          .toString()
          .withMultiplierTrade(positions.sym, floor: false),
    );
  }

  static bool isMarketStarted(Symbols positions) {
    AmoMktTimings? amoMktTimings = AppConfig.amoMktTimings
        .firstWhereOrNull((element) => element.exc == positions.sym?.exc);
    bool isMarketStarted = true;
    if (amoMktTimings != null) {
      try {
        DateTime now = DateTime.now().toUtc();
        DateTime startTime = DateTime.utc(
                now.year,
                now.month,
                now.day,
                AppUtils().intValue(amoMktTimings.mktStartTime!.split(":")[0]),
                AppUtils().intValue(amoMktTimings.mktStartTime!.split(":")[1]))
            .subtract(const Duration(hours: 5, minutes: 30));
        isMarketStarted = (now.isAfter(startTime));
      } catch (e) {
        isMarketStarted = false;
      }
    }
    return isMarketStarted;
  }

  static currentValuePosition(Positions positions) {
    String calculatedvalue = AppUtils().doubleValue(positions.netQty) == 0
        ? ((AppUtils().doubleValue(positions.cfSellAvgPrice) *
                    AppUtils().doubleValue(positions.cfSellQty) +
                (AppUtils().doubleValue(positions.daySellAvgPrice) *
                    AppUtils().doubleValue(positions.daySellQty))))
            .abs()
            .toString()
        : (AppUtils().doubleValue(positions.ltp) *
                AppUtils().doubleValue(positions.netQty))
            .abs()
            .toString();

    return AppUtils().commaFmt(
      calculatedvalue.withMultiplierTrade(positions.sym, floor: false),
    );
  }

  static String overallPnLPosition(Positions positions) {
    double daybuyAvgPrice = AppUtils().doubleValue(positions.dayBuyAvgPrice);
    double daysellAvgPrice = AppUtils().doubleValue(positions.daySellAvgPrice);
    double ltp = AppUtils().doubleValue(positions.ltp);
    double cfBuyAvgPrice = AppUtils().doubleValue(positions.cfBuyAvgPrice);
    double cfSellAvgPrice = AppUtils().doubleValue(positions.cfSellAvgPrice);
    double cfprice = AppUtils().intValue(positions.cfBuyQty) != 0
        ? cfBuyAvgPrice
        : cfSellAvgPrice;
    int dayBuyQty = AppUtils().intValue(positions.dayBuyQty);
    int daySellQty = AppUtils().intValue(positions.daySellQty);

    int cfBuyQty = AppUtils().intValue(positions.cfBuyQty);
    int cfSellQty = AppUtils().intValue(positions.cfSellQty);
    double carryQtyOverallPnl = (ltp - cfprice) * (cfBuyQty - cfSellQty);
    double todayQtyOverallPnl = ((ltp - daybuyAvgPrice) * dayBuyQty) +
        ((daysellAvgPrice - ltp) * daySellQty);
    return AppUtils().commaFmt(
      AppUtils()
          .isValueNAN(carryQtyOverallPnl + todayQtyOverallPnl)
          .toString()
          .withMultiplierTrade(positions.sym, floor: false),
    );
  }

  static bool isMarketStartedOrders(Orders orders) {
    List<String> gtdTiming =
        AppConfig.gtdTiming?.replaceFirst(RegExp('-'), ',').split(',') ?? [];

    bool isMarketStarted = true;
    try {
      DateTime now = DateTime.now().toUtc();

      DateTime startTime = DateTime.utc(
              now.year,
              now.month,
              now.day,
              AppUtils().intValue(gtdTiming[0].split(":")[0]),
              AppUtils().intValue(gtdTiming[0].split(":")[1]))
          .subtract(const Duration(hours: 5, minutes: 30));

      DateTime endTime = DateTime.utc(
              now.year,
              now.month,
              now.day,
              AppUtils().intValue(gtdTiming[1].split(":")[0]),
              AppUtils().intValue(gtdTiming[1].split(":")[1]))
          .subtract(const Duration(hours: 5, minutes: 30));
      isMarketStarted = (now.isAfter(startTime) && now.isBefore(endTime));
    } catch (e) {
      isMarketStarted = false;
    }

    log(isMarketStarted.toString());
    return isMarketStarted;
  }

  static String overallPnLPercentPosition(Positions positions) {
    double calculatedvalue = 0.00;

    calculatedvalue = ((AppUtils().doubleValue(positions.overallPnL) /
            AppUtils().doubleValue(positions.invested)) *
        100);

    return AppUtils().commaFmt(
      AppUtils().decimalValue(
        AppUtils().isValueNAN(calculatedvalue),
      ),
    );
  }

  static String oneDayPnlPercentPosition(Positions positions) {
    double onedayPnlPercent = ((AppUtils().doubleValue(positions.oneDayPnL) /
            AppUtils().doubleValue(positions.invested)) *
        100);
    return AppUtils().commaFmt(
      AppUtils().decimalValue(
        AppUtils().isValueNAN(onedayPnlPercent),
      ),
    );
  }

  static String investedValuePosition(Positions positions) {
    final double calculatedvalue = AppUtils().doubleValue(positions.netQty) == 0
        ? ((AppUtils().doubleValue(positions.dayBuyQty) +
                AppUtils().doubleValue(positions.cfBuyQty)) *
            AppUtils().doubleValue(positions.buyAvgPrice))
        : (AppUtils().doubleValue(positions.avgPrice) *
                (AppUtils().doubleValue(positions.netQty)))
            .abs();
    return AppUtils().commaFmt(
      calculatedvalue
          .toString()
          .withMultiplierTrade(positions.sym, floor: false),
    );
  }

  static String totalInvestedPosition(List<Positions> positions) {
    double value = positions.fold(0, (double previousValue, Symbols element) {
      if (element.invested != null && element.invested!.isNotEmpty) {
        return previousValue + AppUtils().doubleValue(element.invested);
      }
      return previousValue + 0.0;
    });

    return AppUtils().commaFmt(AppUtils().decimalValue(value));
  }

  static String totalOneDayPnlPosition(List<Positions> positions) {
    double value = positions.fold(0, (double previousValue, Positions element) {
      if (element.oneDayPnL != null && element.oneDayPnL!.isNotEmpty) {
        return previousValue + AppUtils().doubleValue(element.oneDayPnL);
      }
      return previousValue + 0.0;
    });

    return AppUtils().commaFmt(AppUtils().decimalValue(value));
  }

  static String totalOverallPnLPosition(List<Positions> positions) {
    double value = positions.fold(0, (double previousValue, Positions element) {
      if (element.overallPnL != null && element.overallPnL!.isNotEmpty) {
        return previousValue + AppUtils().doubleValue(element.overallPnL);
      }
      return previousValue + 0.0;
    });

    return AppUtils().commaFmt(AppUtils().decimalValue(value));
  }

  static String totalOverallPnlPercentPosition(List<Positions> positions) {
    double overallPnl =
        positions.fold(0, (double previousValue, Positions element) {
      if (element.overallPnL != null && element.overallPnL!.isNotEmpty) {
        return previousValue + AppUtils().doubleValue(element.overallPnL);
      }
      return previousValue + 0.0;
    });
    double invested =
        positions.fold(0, (double previousValue, Positions element) {
      if (element.invested != null && element.invested!.isNotEmpty) {
        return previousValue + AppUtils().doubleValue(element.invested);
      }
      return previousValue + 0.0;
    });
    double value = (overallPnl / invested.abs()) * 100;
    return AppUtils()
        .commaFmt(AppUtils().decimalValue(value.isNaN ? "0.00" : value));
  }

  static String totalOneDayPnlPercentPosition(List<Positions> positions) {
    double totalInvestment =
        positions.fold(0, (double previousValue, Positions element) {
      if (element.oneDayPnL != null && element.oneDayPnL!.isNotEmpty) {
        return previousValue + AppUtils().doubleValue(element.invested);
      }
      return previousValue + 0.0;
    });
    double daysTotalPnl =
        positions.fold(0, (double previousValue, Positions element) {
      if (element.oneDayPnL != null && element.oneDayPnL!.isNotEmpty) {
        return previousValue + AppUtils().doubleValue(element.oneDayPnL);
      }
      return previousValue + 0.0;
    });

    double value = (daysTotalPnl / totalInvestment.abs()) * 100;
    return AppUtils()
        .commaFmt(AppUtils().decimalValue(value.isNaN ? 0.00 : value));
  }
}
