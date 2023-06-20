import 'corporate_action.dart';
import 'data_point_base.dart';

class Splits extends CorporateAction {
  Splits(msg, dataPoints) : super(msg, dataPoints);

  Splits.fromJson(Map<String, dynamic> json) : super.fromJson() {
    msg = json['msg'];
    if (json['dataPoints'] != null) {
      dataPoints.dataPoints.clear();
      json['dataPoints'].forEach((v) {
        dataPoints.addDataPoint(SplitsDataPoint.fromJson(v));
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

class SplitsDataPoint extends DataPointBase {
  String? spltDte;
  String? recordDate;
  String? fvBefore;
  String? remark;
  String? noEmdDte;
  String? noStrtDte;
  String? anncmntDate;
  String? ratio;
  String? desc;
  String? fvAftr;

  SplitsDataPoint(
      {this.spltDte,
      this.recordDate,
      this.fvBefore,
      this.remark,
      this.noEmdDte,
      this.noStrtDte,
      this.anncmntDate,
      this.ratio,
      this.desc,
      this.fvAftr})
      : super(type: DataPointType.SPLITS);

  SplitsDataPoint.fromJson(Map<String, dynamic> json) {
    spltDte = json['spltDte'];
    recordDate = json['recordDate'];
    fvBefore = json['fvBefore'];
    remark = json['remark'];
    noEmdDte = json['noEmdDte'];
    noStrtDte = json['noStrtDte'];
    anncmntDate = json['anncmntDate'];
    ratio = json['ratio'];
    desc = json['desc'];
    fvAftr = json['fvAftr'];
    type = DataPointType.SPLITS;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['spltDte'] = spltDte;
    data['recordDate'] = recordDate;
    data['fvBefore'] = fvBefore;
    data['remark'] = remark;
    data['noEmdDte'] = noEmdDte;
    data['noStrtDte'] = noStrtDte;
    data['anncmntDate'] = anncmntDate;
    data['ratio'] = ratio;
    data['desc'] = desc;
    data['fvAftr'] = fvAftr;
    return data;
  }
}
