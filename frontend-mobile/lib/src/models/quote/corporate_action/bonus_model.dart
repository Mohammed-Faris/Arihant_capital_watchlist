import 'corporate_action.dart';

import 'data_point_base.dart';

class Bonus extends CorporateAction {
  Bonus(msg, dataPoints) : super(msg, dataPoints);

  Bonus.fromJson(Map<String, dynamic> json) : super.fromJson() {
    msg = json['msg'];
    if (json['dataPoints'] != null) {
      dataPoints.dataPoints.clear();
      json['dataPoints'].forEach((v) {
        dataPoints.addDataPoint(BonusDataPoint.fromJson(v));
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

class BonusDataPoint extends DataPointBase {
  String? bonusDte;
  String? recordDate;
  String? remark;
  String? anncmntDate;
  String? ratio;
  String? desc;

  BonusDataPoint(
      {this.bonusDte,
      this.recordDate,
      this.remark,
      this.anncmntDate,
      this.ratio,
      this.desc})
      : super(type: DataPointType.BONUS);

  BonusDataPoint.fromJson(Map<String, dynamic> json) {
    bonusDte = json['bonusDte'];
    recordDate = json['recordDate'];
    remark = json['remark'];
    anncmntDate = json['anncmntDate'];
    ratio = json['ratio'];
    desc = json['desc'];
    type = DataPointType.BONUS;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['bonusDte'] = bonusDte;
    data['recordDate'] = recordDate;
    data['remark'] = remark;
    data['anncmntDate'] = anncmntDate;
    data['ratio'] = ratio;
    data['desc'] = desc;
    return data;
  }
}
