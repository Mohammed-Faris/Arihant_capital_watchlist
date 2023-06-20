import 'package:msil_library/models/base/base_model.dart';

class FIIDIIModel extends BaseModel {
  FIIDIIModel({
    required this.fiiDii,
  });
  late final List<FiiDii> fiiDii;

  FIIDIIModel.fromJson(Map<String, dynamic> json) : super.fromJSON(json) {
    fiiDii = List.from(data['fiiDii']).map((e) => FiiDii.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['fiiDii'] = fiiDii.map((e) => e.toJson()).toList();
    return data;
  }
}

class FiiDii {
  FiiDii({
    required this.date,
    required this.fiiFuture,
    required this.diiCash,
    required this.fiiOption,
    required this.fiiCash,
  });
  late final String date;
  late final String fiiFuture;
  late final String diiCash;
  late final String fiiOption;
  late final String fiiCash;

  FiiDii.fromJson(Map<String, dynamic> json) {
    date = json['date'];
    fiiFuture = json['fiiFuture'] ?? "--";
    diiCash = json['diiCash'] ?? "--";
    fiiOption = json['fiiOption'] ?? "--";
    fiiCash = json['fiiCash'] ?? "--";
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['date'] = date;
    data['fiiFuture'] = fiiFuture;
    data['diiCash'] = diiCash;
    data['fiiOption'] = fiiOption;
    data['fiiCash'] = fiiCash;
    return data;
  }
}
