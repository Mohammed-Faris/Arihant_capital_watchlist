import 'package:msil_library/models/base/base_model.dart';

import '../common/sym_model.dart';

class CreateorModifyAlertModel extends BaseModel {
  CreateorModifyAlertModel({
    required this.alertCriteria,
    required this.sym,
    this.alertID,this.alertName
  });
  late final AlertCriteria alertCriteria;
  late final Sym sym;
  late final String? alertID;
  late final String? alertName;

  CreateorModifyAlertModel.fromJson(Map<String, dynamic> json)
      : super.fromJSON(json) {
    alertCriteria = AlertCriteria.fromJson(data['alertCriteria']);
    sym = Sym.fromJson(data['sym']);
    alertID = data['alertID'];
    alertName = data['alertName'] ?? "";
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['alertCriteria'] = alertCriteria.toJson();
    data['notifyType'] = ["P","S","E"];
    data['alertID'] = alertID;
    data['alertName'] = alertName;
    data['sym'] = sym.toJson();
    return data;
  }
}

class AlertCriteria {
  AlertCriteria({
    required this.criteriaType,
    required this.criteriaVal,
  });
  late final String criteriaType;
  late final String criteriaVal;

  AlertCriteria.fromJson(Map<String, dynamic> json) {
    criteriaType = json['criteriaType'];
    criteriaVal = json['criteriaVal'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['criteriaType'] = criteriaType;
    data['criteriaVal'] = criteriaVal;
    return data;
  }
}
