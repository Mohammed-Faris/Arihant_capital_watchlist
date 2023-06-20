import 'package:msil_library/models/base/base_model.dart';

class Basketmodel extends BaseModel {
  Basketmodel({
    required this.baskets,
  });
  List<Baskets> baskets = [];

  Basketmodel.fromJson(Map<String, dynamic> json) : super.fromJSON(json) {
    baskets =
        List.from(data['baskets']).map((e) => Baskets.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['baskets'] = baskets.map((e) => e.toJson()).toList();
    return data;
  }
}

class Baskets {
  Baskets({
    required this.basketId,
    required this.basketName,
    required this.basktCrtdAt,
    required this.ordCount,
  });
  late final String basketId;
  late final String basketName;
  late final String basktCrtdAt;
  late final String ordCount;

  Baskets.fromJson(Map<String, dynamic> json) {
    basketId = json['basketId'];
    basketName = json['basketName'];
    basktCrtdAt = json['basktCrtdAt'];
    ordCount = json['ordCount'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['basketId'] = basketId;
    data['basketName'] = basketName;
    data['basktCrtdAt'] = basktCrtdAt;
    data['ordCount'] = ordCount;
    return data;
  }
}
