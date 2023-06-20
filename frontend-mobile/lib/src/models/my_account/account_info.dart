import 'package:msil_library/models/base/base_model.dart';

class AccountInfo extends BaseModel {
  AccountInfo({
    required this.exchEnabledKeyArr,
    required this.dpAccountNo,
    required this.product,
    required this.bankdtls,
    required this.accountName,
    required this.accountType,
    required this.bankAccountNo,
    required this.bankName,
    required this.panNumber,
    required this.dobAccount,
    required this.phoneNo,
    required this.accountStatus,
    required this.accountId,
    required this.sBrokerName,
    required this.cellAddr,
    required this.emailAddr,
    required this.exchEnabledValueArr,
    required this.customerId,
    required this.depository,
    required this.user,
  });
  late final List<String> exchEnabledKeyArr;
  late final String dpAccountNo;
  late final List<String> product;
  late final List<Bankdtls> bankdtls;
  late final String accountName;
  late final String accountType;
  late final String bankAccountNo;
  late final String bankName;
  late final String panNumber;
  late final String dobAccount;
  late final String phoneNo;
  late final String accountStatus;
  late final String accountId;
  late final String sBrokerName;
  late final String cellAddr;
  late final String emailAddr;
  late final List<String> exchEnabledValueArr;
  late final String customerId;
  late final String depository;
  late final String user;

  AccountInfo.fromJson(Map<String, dynamic> json) : super.fromJSON(json) {
    exchEnabledKeyArr =
        List.castFrom<dynamic, String>(data['exchEnabledKeyArr']);
    dpAccountNo = data['dpAccountNo'];
    product = List.castFrom<dynamic, String>(data['product']);
    bankdtls =
        List.from(data['bankdtls']).map((e) => Bankdtls.fromJson(e)).toList();
    accountName = data['accountName'] ?? "";
    accountType = data['accountType'] ?? "";
    bankAccountNo = data['bankAccountNo'] ?? "";
    bankName = data['bankName'] ?? "";
    panNumber = data['panNumber'] ?? "";
    dobAccount = data['dobAccount'] ?? "";
    phoneNo = data['phoneNo'] ?? "";
    accountStatus = data['accountStatus'] ?? "";
    accountId = data['accountId'] ?? "";
    sBrokerName = data['sBrokerName'] ?? "";
    cellAddr = data['cellAddr'] ?? "";
    emailAddr = data['emailAddr'] ?? "";
    exchEnabledValueArr =
        List.castFrom<dynamic, String>(data['exchEnabledValueArr'] ?? []);
    customerId = data['customerId'] ?? "";
    depository = data['depository'] ?? "";
    user = data['user'] ?? "";
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['exchEnabledKeyArr'] = exchEnabledKeyArr;
    data['dpAccountNo'] = dpAccountNo;
    data['product'] = product;
    data['bankdtls'] = bankdtls.map((e) => e.toJson()).toList();
    data['accountName'] = accountName;
    data['accountType'] = accountType;
    data['bankAccountNo'] = bankAccountNo;
    data['bankName'] = bankName;
    data['panNumber'] = panNumber;
    data['dobAccount'] = dobAccount;
    data['phoneNo'] = phoneNo;
    data['accountStatus'] = accountStatus;
    data['accountId'] = accountId;
    data['sBrokerName'] = sBrokerName;
    data['cellAddr'] = cellAddr;
    data['emailAddr'] = emailAddr;
    data['exchEnabledValueArr'] = exchEnabledValueArr;
    data['customerId'] = customerId;
    data['depository'] = depository;
    data['user'] = user;
    return data;
  }
}

class Bankdtls {
  Bankdtls({
    required this.bankBranchName,
    required this.bankAccountNo,
    required this.bankAddres,
    required this.bankName,
  });
  late final String bankBranchName;
  late final String bankAccountNo;
  late final String bankAddres;
  late final String bankName;

  Bankdtls.fromJson(Map<String, dynamic> json) {
    bankBranchName = json['bankBranchName'] ?? "";
    bankAccountNo = json['bankAccountNo'] ?? "";
    bankAddres = json['bankAddres'] ?? "";
    bankName = json['bankName'] ?? "";
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['bankBranchName'] = bankBranchName;
    data['bankAccountNo'] = bankAccountNo;
    data['bankAddres'] = bankAddres;
    data['bankName'] = bankName;
    return data;
  }
}
