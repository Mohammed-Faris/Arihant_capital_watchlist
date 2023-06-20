// ignore_for_file: overridden_fields

import 'package:msil_library/models/base/base_model.dart';

import '../orders/order_book.dart';

class BasketOrderBook extends BaseModel {
  List<Orders>? orders;
  String? basketName;
  bool isexecuteAllorder = false;

  BasketOrderBook({this.orders});

  BasketOrderBook.fromJson(Map<String, dynamic> json) : super.fromJSON(json) {
    if (data['orders'] != null) {
      orders = <Orders>[];
      data['orders'].forEach((v) {
        Orders order = Orders.fromJson(v);
        orders!.add(order);
      });
      basketName = data["basketName"];
      isexecuteAllorder = (orders?.isNotEmpty ?? false) &&
          (orders
                  ?.where((element) => (element.isModifiable == false &&
                      element.isExecutable == false))
                  .toList()
                  .length ==
              orders?.length);
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['orders'] = orders!.map((v) => v.toJson()).toList();
    data["basketName"] = basketName;
    return data;
  }
}
