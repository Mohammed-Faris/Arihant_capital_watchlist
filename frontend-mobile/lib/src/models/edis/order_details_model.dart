class OrderDetails {
  String? isin;
  String? qty;

  OrderDetails({this.isin, this.qty});

  OrderDetails.fromJson(Map<String, dynamic> json) {
    isin = json['isin'];
    qty = json['qty'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['isin'] = isin ?? '';
    data['qty'] = qty ?? '';
    return data;
  }
}
