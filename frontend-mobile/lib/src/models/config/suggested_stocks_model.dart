import 'package:acml/src/data/store/app_utils.dart';

import '../../constants/app_constants.dart';
import '../common/sym_model.dart';
import '../common/symbols_model.dart';

class SuggestedStocks extends Symbols {
  SuggestedStocks();

  SuggestedStocks.fromJson(Map<String, dynamic> json) {
    dispSym = json['dispSym'];
    sym = json['sym'] != null ? Sym.fromJson(json['sym']) : null;
    companyName = json['companyName'];
    baseSym = json['baseSym'];
    isFno = json['isFno'] == "true";
    if (AppUtils().getsymbolTypeFromSym(sym) == AppConstants.fno) {
      isFno = true;
    }
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['dispSym'] = dispSym;
    if (sym != null) {
      data['sym'] = sym!.toJson();
    }
    data['isFno'] = isFno.toString();

    data['companyName'] = companyName;
    data['baseSym'] = baseSym;
    return data;
  }
}
