class BinarySpecMatrixModel {
  late String type;
  late String key;
  late int len;
  Function? fmt;

  BinarySpecMatrixModel({
    required this.type,
    required this.key,
    required this.len,
    this.fmt,
  });

  BinarySpecMatrixModel.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    key = json['key'];
    len = json['len'];
    fmt = json['fmt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = this.type;
    data['key'] = this.key;
    data['len'] = this.len;
    data['fmt'] = this.fmt;
    return data;
  }
}
