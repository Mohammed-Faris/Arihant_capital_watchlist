import 'id_properties_model.dart';

class StreamDetailsModel {
  late IdPropertiesModel idProperties;
  List<dynamic>? symbols;

  StreamDetailsModel({required this.idProperties, this.symbols});

  StreamDetailsModel.fromJson(Map<String, dynamic> json) {
    idProperties = json['idProperties'];
    symbols = json['symbols'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['idProperties'] = this.idProperties;
    if (this.symbols != null) {
      data['symbols'] = this.symbols!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
