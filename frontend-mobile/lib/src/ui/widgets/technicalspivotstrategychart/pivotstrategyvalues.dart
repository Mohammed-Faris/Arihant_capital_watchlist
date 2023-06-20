class PivotStrategyValues {
  late String s3;
  late String r2;
  late String r3;
  late String pivot;
  late String s1;
  late String s2;
  late String r1;

  PivotStrategyValues(
      {required this.s3,
      required this.r2,
      required this.r3,
      required this.pivot,
      required this.s1,
      required this.s2,
      required this.r1});

  PivotStrategyValues.fromJson(Map<String, dynamic> json) {
    s3 = json['S3'];
    r2 = json['R2'];
    r3 = json['R3'];
    pivot = json['PIVOT'];
    s1 = json['S1'];
    s2 = json['S2'];
    r1 = json['R1'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['S3'] = s3;
    data['R2'] = r2;
    data['R3'] = r3;
    data['PIVOT'] = pivot;
    data['S1'] = s1;
    data['S2'] = s2;
    data['R1'] = r1;
    return data;
  }
}
