class IdPropertiesModel {
  late String screenName;
  Function? callBack;
  late List<String> streamingKeys;

  IdPropertiesModel({
    required this.screenName,
    required this.streamingKeys,
    this.callBack,
  });

  IdPropertiesModel.fromJson(Map<String, dynamic> json) {
    screenName = json['screenName'];
    callBack = json['callBack'];
    streamingKeys = json['streamingKeys'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['screenName'] = screenName;
    data['callBack'] = callBack;
    data['streamingKeys'] = streamingKeys;
    return data;
  }
}
