import 'package:msil_library/models/base/base_model.dart';

class VolumeAnalysis extends BaseModel {
  String? delVol1M;
  String? delVolPrev;
  String? totVolPrev;
  String? totVol1M;
  String? delVol1wk;
  String? totVol1wk;
  String? totVol;
  String? delVol;
  List<ChartData>? chartdat;
  VolumeAnalysis(
      {this.delVol1M,
      this.delVolPrev,
      this.totVolPrev,
      this.totVol1M,
      this.delVol1wk,
      this.chartdat,
      this.totVol1wk,
      this.totVol,
      this.delVol});

  VolumeAnalysis.fromJson(Map<String, dynamic> json) : super.fromJSON(json) {
    delVol1M = data['delVol1M'];
    delVolPrev = data['delVolPrev'];
    totVolPrev = data['totVolPrev'];
    totVol1M = data['totVol1M'];
    delVol1wk = data['delVol1wk'];
    totVol1wk = data['totVol1wk'];
    totVol = data['totVol'];
    delVol = data['delVol'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['delVol1M'] = delVol1M;
    data['delVolPrev'] = delVolPrev;
    data['totVolPrev'] = totVolPrev;
    data['totVol1M'] = totVol1M;
    data['delVol1wk'] = delVol1wk;
    data['totVol1wk'] = totVol1wk;
    data['totVol'] = totVol;
    data['delVol'] = delVol;
    return data;
  }
}

class ChartData {
  final double volume;
  final double totalVolume;
  final String title;
  bool showData;
  ChartData(this.volume, this.totalVolume, this.title, this.showData);
}
