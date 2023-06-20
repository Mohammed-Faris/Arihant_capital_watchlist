import 'bonus_model.dart';
import 'dividend_model.dart';
import 'rights_model.dart';
import 'splits_model.dart';
import 'package:msil_library/models/base/base_model.dart';

class QuoteCorporateActionModel extends BaseModel {
  Splits? splits;
  Bonus? bonus;
  Rights? rights;
  Dividend? dividend;

  QuoteCorporateActionModel(
      {this.splits, this.bonus, this.rights, this.dividend});

  QuoteCorporateActionModel.fromJson(Map<String, dynamic> json)
      : super.fromJSON(json) {
    splits = data['splits'] != null ? Splits.fromJson(data['splits']) : null;
    bonus = data['bonus'] != null ? Bonus.fromJson(data['bonus']) : null;
    rights = data['rights'] != null ? Rights.fromJson(data['rights']) : null;
    dividend =
        data['dividend'] != null ? Dividend.fromJson(data['dividend']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (splits != null) {
      data['splits'] = splits!.toJson();
    }
    if (bonus != null) {
      data['bonus'] = bonus!.toJson();
    }
    if (rights != null) {
      data['rights'] = rights!.toJson();
    }
    if (dividend != null) {
      data['dividend'] = dividend!.toJson();
    }
    return data;
  }
}
