import '../common/symbols_model.dart';
import '../sort_filter/sort_filter_model.dart';
import 'package:msil_library/models/base/base_model.dart';

class IndicesConstituentsModel extends BaseModel {
  late List<Symbols> result;
  List<FilterModel>? selectedFilter;
  SortModel? selectedSort;
  IndicesConstituentsModel(this.result, this.selectedFilter);

  IndicesConstituentsModel.fromJson(Map<String, dynamic> json)
      : super.fromJSON(json) {
    if (data['RESULT'] != null) {
      result = <Symbols>[];
      data['RESULT'].forEach((dynamic v) {
        result.add(Symbols.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['RESULT'] = <Map<String, dynamic>>[];
    for (final Symbols item in result) {
      final Map<String, dynamic> result = item.toJson();
      data['RESULT'].add(result);
    }

    return data;
  }
}
