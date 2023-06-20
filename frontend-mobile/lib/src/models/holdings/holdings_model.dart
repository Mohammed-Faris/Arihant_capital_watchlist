import 'package:msil_library/models/base/base_model.dart';

import '../common/symbols_model.dart';

class HoldingsModel extends BaseModel {
  String? overallReturn;
  String? overallReturnPercent;
  String? oneDayReturn;
  String? oneDayReturnPercent;
  String? overallcurrentValue;
  String? totalInvested;
  List<Symbols>? holdings;

  HoldingsModel(
    this.holdings,
  );

  HoldingsModel.fromJson(Map<String, dynamic> json) : super.fromJSON(json) {
    if (data['holdings'] != null) {
      holdings = <Symbols>[];
      data['holdings'].forEach(
        (dynamic v) {
          holdings!.add(Symbols.fromJson(v));
        },
      );
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['holdings'] = holdings!.map((dynamic v) => v.toJson()).toList();

    return data;
  }
}
