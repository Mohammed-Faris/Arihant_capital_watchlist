import 'corporate_action.dart';
import 'data_point_base.dart';

class Rights extends CorporateAction {
  Rights(msg, dataPoints) : super(msg, dataPoints);

  Rights.fromJson(Map<String, dynamic> json) : super.fromJson() {
    msg = json['msg'];
    if (json['dataPoints'] != null) {
      dataPoints.dataPoints.clear();
      json['dataPoints'].forEach((v) {
        dataPoints.addDataPoint(RightsDataPoint.fromJson(v));
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

class RightsDataPoint extends DataPointBase {
  String? premium;
  String? rightRatio;
  String? recordDate;
  String? remark;
  String? noEmdDte;
  String? noStrtDte;
  String? anncmntDate;
  String? rightDte;
  String? desc;

  RightsDataPoint(
      {this.premium,
      this.rightRatio,
      this.recordDate,
      this.remark,
      this.noEmdDte,
      this.noStrtDte,
      this.anncmntDate,
      this.rightDte,
      this.desc})
      : super(type: DataPointType.RIGHTS);

  RightsDataPoint.fromJson(Map<String, dynamic> json) {
    premium = json['premium'];
    rightRatio = json['rightRatio'];
    recordDate = json['recordDate'];
    remark = json['remark'];
    noEmdDte = json['noEmdDte'];
    noStrtDte = json['noStrtDte'];
    anncmntDate = json['anncmntDate'];
    rightDte = json['rightDte'];
    desc = json['desc'];
    type = DataPointType.RIGHTS;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['premium'] = premium;
    data['rightRatio'] = rightRatio;
    data['recordDate'] = recordDate;
    data['remark'] = remark;
    data['noEmdDte'] = noEmdDte;
    data['noStrtDte'] = noStrtDte;
    data['anncmntDate'] = anncmntDate;
    data['rightDte'] = rightDte;
    data['desc'] = desc;
    return data;
  }
}
