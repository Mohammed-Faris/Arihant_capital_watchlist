// class MarketIndicesModel {
//   List<NSE>? nSE;
//   List<BSE>? bSE;
//
//   MarketIndicesModel({this.nSE, this.bSE});
//
//   MarketIndicesModel.fromJson(Map<String, dynamic> json) {
//     if (json['NSE'] != null) {
//       nSE = <NSE>[];
//       json['NSE'].forEach((v) {
//         nSE!.add(new NSE.fromJson(v));
//       });
//     }
//     if (json['BSE'] != null) {
//       bSE = <BSE>[];
//       json['BSE'].forEach((v) {
//         bSE!.add(new BSE.fromJson(v));
//       });
//     }
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     if (this.nSE != null) {
//       data['NSE'] = this.nSE!.map((v) => v.toJson()).toList();
//     }
//     if (this.bSE != null) {
//       data['BSE'] = this.bSE!.map((v) => v.toJson()).toList();
//     }
//     return data;
//   }
// }
//
// class NSE {
//   String? dispSym;
//   Sym? sym;
//   String? baseSym;
//   bool? hasFutOpt;
//
//   NSE({this.dispSym, this.sym, this.baseSym, this.hasFutOpt});
//
//   NSE.fromJson(Map<String, dynamic> json) {
//     dispSym = json['dispSym'];
//     sym = json['sym'] != null ? new Sym.fromJson(json['sym']) : null;
//     baseSym = json['baseSym'];
//     hasFutOpt = json['hasFutOpt'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['dispSym'] = this.dispSym;
//     if (this.sym != null) {
//       data['sym'] = this.sym!.toJson();
//     }
//     data['baseSym'] = this.baseSym;
//     data['hasFutOpt'] = this.hasFutOpt;
//     return data;
//   }
// }
//
// class BSE {
//   String? dispSym;
//   Sym? sym;
//   String? baseSym;
//   bool? hasFutOpt;
//
//   BSE({this.dispSym, this.sym, this.baseSym, this.hasFutOpt});
//
//   BSE.fromJson(Map<String, dynamic> json) {
//     dispSym = json['dispSym'];
//     sym = json['sym'] != null ? new Sym.fromJson(json['sym']) : null;
//     baseSym = json['baseSym'];
//     hasFutOpt = json['hasFutOpt'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['dispSym'] = this.dispSym;
//     if (this.sym != null) {
//       data['sym'] = this.sym!.toJson();
//     }
//     data['baseSym'] = this.baseSym;
//     data['hasFutOpt'] = this.hasFutOpt;
//     return data;
//   }
// }
//
// class Sym {
//   String? exc;
//   String? streamSym;
//   String? instrument;
//   String? id;
//   String? asset;
//   String? excToken;
//
//   Sym(
//       {this.exc,
//       this.streamSym,
//       this.instrument,
//       this.id,
//       this.asset,
//       this.excToken});
//
//   Sym.fromJson(Map<String, dynamic> json) {
//     exc = json['exc'];
//     streamSym = json['streamSym'];
//     instrument = json['instrument'];
//     id = json['id'];
//     asset = json['asset'];
//     excToken = json['excToken'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['exc'] = this.exc;
//     data['streamSym'] = this.streamSym;
//     data['instrument'] = this.instrument;
//     data['id'] = this.id;
//     data['asset'] = this.asset;
//     data['excToken'] = this.excToken;
//     return data;
//   }
// }
