class Sym {
  late String? exc;
  late String? streamSym;
  late String? instrument;
  late String? id;
  late String? asset;
  late String? excToken;
  late List<dynamic>? otherExch;
  late String? expiry;
  late String? optionType;
  late String? lotSize;
  late String? strike;
  late String? baseSym;
  late String? tickSize;
  late String? multiplier;
  late String? series;
  String? dispSym;
  bool isWeekly = false;
  Sym({
    this.exc,
    required this.streamSym,
    this.instrument,
    this.id,
    this.asset,
    this.excToken,
    this.otherExch,
    this.expiry,
    this.optionType,
    this.lotSize,
    this.strike,
    this.baseSym,
    this.tickSize,
    this.multiplier,
    this.series,
    this.dispSym,
  });

  Sym.fromJson(Map<String, dynamic> json) {
    exc = json['exc'];
    streamSym = json['streamSym'];
    instrument = json['instrument'];
    id = json['id'];
    asset = json['asset'];
    excToken = json['excToken'];
    otherExch = json['otherExch'];
    expiry = json['expiry'];
    optionType = json['optionType'];
    lotSize = json['lotSize'];
    strike = json['strike'];
    baseSym = json['baseSym'];
    tickSize = json['tickSize'];
    multiplier = json['multiplier'];
    series = json['series'];
    isWeekly = json["isWeekly"] ?? false;

    dispSym = json['dispSym'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['exc'] = exc;
    data['streamSym'] = streamSym;
    data['instrument'] = instrument;
    data['id'] = id;
    data['asset'] = asset;
    data['excToken'] = excToken;
    data['otherExch'] = otherExch;
    data['expiry'] = expiry;
    data['optionType'] = optionType;
    data['lotSize'] = lotSize;
    data['strike'] = strike;
    data['isWeekly'] = isWeekly;

    data['baseSym'] = baseSym;
    data['tickSize'] = tickSize;
    data['multiplier'] = multiplier;
    data['series'] = series;
    data['dispSym'] = dispSym;

    return data;
  }

  Sym.copyModel(Sym symModel) {
    copyModel(symModel);
  }

  void copyModel(Sym symModel) {
    exc = symModel.exc;
    streamSym = symModel.streamSym;
    instrument = symModel.instrument;
    id = symModel.id;
    asset = symModel.asset;
    excToken = symModel.excToken;
    otherExch = symModel.otherExch;
    expiry = symModel.expiry;
    optionType = symModel.optionType;
    lotSize = symModel.lotSize;
    strike = symModel.strike;
    baseSym = symModel.baseSym;
    tickSize = symModel.tickSize;
    multiplier = symModel.multiplier;
    series = symModel.series;
    dispSym = symModel.dispSym;
  }
}
