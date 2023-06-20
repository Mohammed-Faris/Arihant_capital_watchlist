import 'corporate_action.dart';
import 'data_point_base.dart';

class Dividend extends CorporateAction {
  Dividend(msg, dataPoints) : super(msg, dataPoints);

  Dividend.fromJson(Map<String, dynamic> json) : super.fromJson() {
    msg = json['msg'];
    if (json['dataPoints'] != null) {
      dataPoints.dataPoints.clear();
      json['dataPoints'].forEach((v) {
        dataPoints.addDataPoint(DividendDataPoint.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['msg'] = msg;
    if (dataPoints.getDataPoints().length > 0) {
      data['dataPoints'] =
          dataPoints.getDataPoints().map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class DividendDataPoint extends DataPointBase {
  String? cmotsCode;
  String? divDate;
  String? companyName;
  String? recordDate;
  String? divPercent;
  String? divType;
  String? dividendAmnt;
  String? symbols;
  String? isin;
  String? anncmntDate;
  String? divPayout;
  String? desc;

  DividendDataPoint({
    this.cmotsCode,
    this.divDate,
    this.companyName,
    this.recordDate,
    this.divPercent,
    this.divType,
    this.dividendAmnt,
    this.symbols,
    this.isin,
    this.anncmntDate,
    this.divPayout,
    this.desc,
  }) : super(type: DataPointType.DIVIDEND);

  DividendDataPoint.fromJson(Map<String, dynamic> json) {
    cmotsCode = json['cmotsCode'];
    divDate = json['divDate'];
    companyName = json['companyName'];
    recordDate = json['recordDate'];
    divPercent = json['divPercent'];
    divType = json['divType'];
    dividendAmnt = json['dividendAmnt'];
    symbols = json['symbols'];
    isin = json['isin'];
    anncmntDate = json['anncmntDate'];
    divPayout = json['divPayout'];
    desc = json['desc'];
    type = DataPointType.DIVIDEND;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['cmotsCode'] = cmotsCode;
    data['divDate'] = divDate;
    data['companyName'] = companyName;
    data['recordDate'] = recordDate;
    data['divPercent'] = divPercent;
    data['divType'] = divType;
    data['dividendAmnt'] = dividendAmnt;
    data['symbols'] = symbols;
    data['isin'] = isin;
    data['anncmntDate'] = anncmntDate;
    data['divPayout'] = divPayout;
    data['desc'] = desc;
    return data;
  }
}
