import '../sort_filter/sort_filter_model.dart';
import 'package:msil_library/models/base/base_model.dart';

class WatchlistGroupModel extends BaseModel {
  List<Groups>? groups;

  WatchlistGroupModel({this.groups});

  WatchlistGroupModel.fromJson(Map<String, dynamic> json)
      : super.fromJSON(json) {
    if (data['groups'] != null) {
      groups = <Groups>[];
      data['groups'].forEach((v) {
        groups!.add(Groups.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (groups != null) {
      data['groups'] = groups!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Groups {
  String? wName;
  String? wId;
  bool? editable;
  bool? defaultMarketWatch;
  int symbolsCount = 0;
  SortModel? selectedSortBy;
  List<FilterModel>? selectedFilter;

  Groups({this.wName, this.wId, this.editable, this.defaultMarketWatch});

  Groups.fromJson(Map<String, dynamic> json) {
    wName = json['wName'];
    wId = json['wId'];
    editable = json['editable'];
    defaultMarketWatch = json['defaultMarketWatch'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['wName'] = wName;
    data['wId'] = wId;
    data['editable'] = editable;
    data['defaultMarketWatch'] = defaultMarketWatch;
    return data;
  }
}
