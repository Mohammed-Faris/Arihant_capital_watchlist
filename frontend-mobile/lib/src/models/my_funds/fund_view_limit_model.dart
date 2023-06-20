import 'package:msil_library/models/base/base_model.dart';

class FundViewLimitModel extends BaseModel {
  String? buypwr;
  String? marginUtilized;
  String? payIn;
  String? cashAvailable;
  String? available;
  String? realizedPNL;
  String? unRealizedPNL;
  String? openBalance;

  FundViewLimitModel(
      {this.buypwr,
      this.marginUtilized,
      this.payIn,
      this.cashAvailable,
      this.available,
      this.realizedPNL,
      this.unRealizedPNL,
      this.openBalance});

  FundViewLimitModel.fromJson(Map<String, dynamic> json)
      : super.fromJSON(json) {
    buypwr = data['buypwr'];
    marginUtilized = data['marginUtilized'];
    payIn = data['payIn'];
    cashAvailable = data['cashAvailable'];
    available = data['available'];
    realizedPNL = data['realizedPNL'];
    unRealizedPNL = data['unRealizedPNL'];
    openBalance = data['openBalance'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['buypwr'] = buypwr;
    data['marginUtilized'] = marginUtilized;
    data['payIn'] = payIn;
    data['cashAvailable'] = cashAvailable;
    data['available'] = available;
    data['realizedPNL'] = realizedPNL;
    data['unRealizedPNL'] = unRealizedPNL;
    data['openBalance'] = openBalance;
    return data;
  }
}
