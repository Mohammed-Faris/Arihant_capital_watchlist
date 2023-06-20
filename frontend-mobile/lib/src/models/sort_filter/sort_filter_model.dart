class SortModel {
  final String? sortName;
  final dynamic sortType;

  SortModel({
    this.sortName,
    this.sortType,
  });
}

class FilterModel {
  String? filterName;
  List<String>? filters;
  List<Filters>? filtersList;

  FilterModel({
    this.filterName,
    this.filters,
    this.filtersList,
  });

  FilterModel.copyModel(FilterModel filterModel) {
    copyModel(filterModel);
  }

  void copyModel(FilterModel filterModel) {
    filterName = filterModel.filterName;
    filters = List.from(filterModel.filters!);
    filtersList = List.from(filterModel.filtersList!);
  }
}

class Filters {
  String? key;
  dynamic value;

  Filters({this.key, this.value});

  Filters.fromJson(Map<String, dynamic> json) {
    key = json['key'];
    value = json['value'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['key'] = key ?? '';
    data['value'] = value;
    return data;
  }
}
