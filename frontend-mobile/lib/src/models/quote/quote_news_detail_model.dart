import '../common/sym_model.dart';
import 'package:msil_library/models/base/base_model.dart';

class QuoteNewsDetailModel extends BaseModel {
  List<CorpNewsDetails>? corpNewsDetails;

  QuoteNewsDetailModel({this.corpNewsDetails});

  QuoteNewsDetailModel.fromJson(Map<String, dynamic> json)
      : super.fromJSON(json) {
    if (data['corpNewsDetails'] != null) {
      corpNewsDetails = <CorpNewsDetails>[];
      data['corpNewsDetails'].forEach((v) {
        corpNewsDetails!.add(CorpNewsDetails.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (corpNewsDetails != null) {
      data['corpNewsDetails'] =
          corpNewsDetails!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class CorpNewsDetails {
  String? date;
  Sym? sym;
  String? caption;
  String? memo;
  String? time;
  String? id;
  String? headng;

  CorpNewsDetails(
      {this.date,
      this.sym,
      this.caption,
      this.memo,
      this.time,
      this.id,
      this.headng});

  CorpNewsDetails.fromJson(Map<String, dynamic> json) {
    date = json['date'];
    sym = json['sym'] != null ? Sym.fromJson(json['sym']) : null;
    caption = json['caption'];
    memo = json['memo'];
    time = json['time'];
    id = json['id'];
    headng = json['headng'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['date'] = date;
    if (sym != null) {
      data['sym'] = sym!.toJson();
    }
    data['caption'] = caption;
    data['memo'] = memo;
    data['time'] = time;
    data['id'] = id;
    data['headng'] = headng;
    return data;
  }
}
