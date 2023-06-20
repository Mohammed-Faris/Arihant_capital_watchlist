import 'package:msil_library/models/base/base_model.dart';

class QuoteKeyStats extends BaseModel {
  Stats? stats;

  QuoteKeyStats({this.stats});

  QuoteKeyStats.fromJson(Map<String, dynamic> json) : super.fromJSON(json) {
    stats = data['stats'] != null ? Stats.fromJson(data['stats']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (stats != null) {
      data['stats'] = stats!.toJson();
    }
    return data;
  }
}

class Stats {
  String? bookValue;
  String? dps;
  String? eps;
  String? divYield;
  String? s1YrRet;
  String? delvryPercent;
  String? s1MRet;
  String? pe;
  String? prcBookVal;
  String? mcap;
  String? s6MRet;
  String? s3YrRet;
  String? beta;

  Stats(
      {this.bookValue,
      this.dps,
      this.eps,
      this.divYield,
      this.s1YrRet,
      this.delvryPercent,
      this.s1MRet,
      this.pe,
      this.prcBookVal,
      this.mcap,
      this.s6MRet,
      this.s3YrRet,
      this.beta});

  Stats.fromJson(Map<String, dynamic> json) {
    bookValue = json['bookValue'];
    dps = json['dps'];
    eps = json['eps'];
    divYield = json['divYield'];
    s1YrRet = json['1YrRet'];
    delvryPercent = json['delvryPercent'];
    s1MRet = json['1MRet'];
    pe = json['pe'];
    prcBookVal = json['prcBookVal'];
    mcap = json['mcap'];
    s6MRet = json['6MRet'];
    s3YrRet = json['3YrRet'];
    beta = json['beta'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['bookValue'] = bookValue;
    data['dps'] = dps;
    data['eps'] = eps;
    data['divYield'] = divYield;
    data['1YrRet'] = s1YrRet;
    data['delvryPercent'] = delvryPercent;
    data['1MRet'] = s1MRet;
    data['pe'] = pe;
    data['prcBookVal'] = prcBookVal;
    data['mcap'] = mcap;
    data['6MRet'] = s6MRet;
    data['3YrRet'] = s3YrRet;
    data['beta'] = beta;
    return data;
  }
}
