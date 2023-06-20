class ClientDetails {
  ClientDetails({
    required this.nomineeContactDtls,
    required this.nomineeNsdl,
    required this.bankDtls,
    required this.nomineeCdsl,
    required this.clientDtls,
  });
  late List<NomineeContactDtls> nomineeContactDtls;
  late List<NomineeNsdl> nomineeNsdl;
  late List<BankDtls> bankDtls;
  late List<NomineeCdsl> nomineeCdsl;
  late List<ClientDtls> clientDtls;

  ClientDetails.fromJson(Map<String, dynamic> json) {
    nomineeContactDtls = json['nomineeContactDtls'] != null
        ? List.from(json['nomineeContactDtls'])
            .map((e) => NomineeContactDtls.fromJson(e))
            .toList()
        : [];
    nomineeNsdl = json['nomineeNsdl'] != null
        ? List.from(json['nomineeNsdl'])
            .map((e) => NomineeNsdl.fromJson(e))
            .toList()
        : [];
    bankDtls = json['bankDtls'] != null
        ? (List.from(json['bankDtls'])
            .map((e) => BankDtls.fromJson(e))
            .toList())
        : [];
    nomineeCdsl = json['nomineeCdsl'] != null
        ? List.from(json['nomineeCdsl'])
            .map((e) => NomineeCdsl.fromJson(e))
            .toList()
        : [];
    clientDtls = json['clientDtls'] != null
        ? List.from(json['clientDtls'])
            .map((e) => ClientDtls.fromJson(e))
            .toList()
        : [];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['nomineeContactDtls'] =
        nomineeContactDtls.map((e) => e.toJson()).toList();
    data['nomineeNsdl'] = nomineeNsdl.map((e) => e.toJson()).toList();
    data['bankDtls'] = bankDtls.map((e) => e.toJson()).toList();
    data['nomineeCdsl'] = nomineeCdsl.map((e) => e.toJson()).toList();
    data['clientDtls'] = clientDtls.map((e) => e.toJson()).toList();
    return data;
  }
}

class NomineeContactDtls {
  NomineeContactDtls({
    required this.dob,
    required this.nomineeName,
    required this.relationship,
  });
  late String dob;
  late String nomineeName;
  late String relationship;

  NomineeContactDtls.fromJson(Map<String, dynamic> json) {
    dob = json['dob'];
    nomineeName = json['nomineeName'];
    relationship = json['relationship'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['dob'] = dob;
    data['nomineeName'] = nomineeName;
    data['relationship'] = relationship;
    return data;
  }
}

class NomineeNsdl {
  NomineeNsdl({
    required this.nomineeAddrs,
    required this.nomineePan,
    required this.nomineeName,
    required this.nomineePinCode,
  });
  late String nomineeAddrs;
  late String nomineePan;
  late String nomineeName;
  late String nomineePinCode;

  NomineeNsdl.fromJson(Map<String, dynamic> json) {
    nomineeAddrs = json['NomineeAddrs'];
    nomineePan = json['NomineePan'];
    nomineeName = json['NomineeName'];
    nomineePinCode = json['nomineePinCode']?.toString() ?? "--";
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['NomineeAddrs'] = nomineeAddrs;
    data['NomineePan'] = nomineePan;
    data['NomineeName'] = nomineeName;
    data['nomineePinCode'] = nomineePinCode;
    return data;
  }
}

class BankDtls {
  BankDtls({
    required this.bankBranch,
    required this.bankName,
    required this.bankAccNo,
    required this.ifsc,
  });
  late String bankBranch;
  late String bankName;
  late String bankAccNo;
  late String ifsc;

  BankDtls.fromJson(Map<String, dynamic> json) {
    bankBranch = json['bankBranch'];
    bankName = json['bankName'];
    bankAccNo = json['bankAccNo'];
    ifsc = json['ifsc'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['bankBranch'] = bankBranch;
    data['bankName'] = bankName;
    data['bankAccNo'] = bankAccNo;
    data['ifsc'] = ifsc;
    return data;
  }
}

class NomineeCdsl {
  NomineeCdsl({
    required this.nomineeAddrs,
    required this.nomineePan,
    required this.nomineeState,
    required this.nomineeName,
  });
  late String nomineeAddrs;
  late String nomineePan;
  late String nomineeState;
  late String nomineeName;

  NomineeCdsl.fromJson(Map<String, dynamic> json) {
    nomineeAddrs = json['NomineeAddrs'] ?? "--";
    nomineePan = json['NomineePan'] ?? "--";
    nomineeState = json['NomineeState'] ?? "--";
    nomineeName = json['NomineeName'] ?? "--";
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['NomineeAddrs'] = nomineeAddrs;
    data['NomineePan'] = nomineePan;
    data['NomineeState'] = nomineeState;
    data['NomineeName'] = nomineeName;
    return data;
  }
}

class ClientDtls {
  ClientDtls({
    required this.corrPinCode,
    required this.depoName,
    required this.permAddrs,
    required this.gender,
    required this.exc,
    required this.mobNo,
    required this.corrCountry,
    required this.permState,
    required this.email,
    required this.mtf,
    required this.fathOrHusName,
    required this.corrCity,
    required this.dematAccNo,
    required this.depoParticipant,
    required this.dpId,
    required this.panNumber,
    required this.corrState,
    required this.dob,
    required this.permCountry,
    required this.name,
    required this.permCity,
    required this.taxResidence,
    required this.permPinCode,
    required this.corrAddrs,
    required this.maritalStatus,
  });
  late String corrPinCode;
  late String depoName;
  late String permAddrs;
  late String gender;
  late List<String> exc;
  late String mobNo;
  late String corrCountry;
  late String permState;
  late String email;
  late String mtf;
  late String fathOrHusName;
  late String corrCity;
  late String dematAccNo;
  late String depoParticipant;
  late String dpId;
  late String panNumber;
  late String corrState;
  late String dob;
  late String permCountry;
  late String name;
  late String permCity;
  late String taxResidence;
  late String permPinCode;
  late String corrAddrs;
  late String maritalStatus;

  ClientDtls.fromJson(Map<String, dynamic> json) {
    corrPinCode = json['corrPinCode'];
    depoName = json['depoName'];
    permAddrs = json['permAddrs'];
    gender = json['gender'];
    exc = List.castFrom<dynamic, String>(json['exc']);
    mobNo = json['mobNo'];
    corrCountry = json['corrCountry'];
    permState = json['permState'];
    email = json['email'];
    mtf = json['mtf'];
    fathOrHusName = json['fathOrHusName'];
    corrCity = json['corrCity'];
    dematAccNo = json['dematAccNo'];
    depoParticipant = json['depoParticipant'];
    dpId = json['dpId'];
    panNumber = json['panNumber'];
    corrState = json['corrState'];
    dob = json['dob'];
    permCountry = json['permCountry'];
    name = json['name'];
    permCity = json['permCity'];
    taxResidence = json['taxResidence'];
    permPinCode = json['permPinCode'];
    corrAddrs = json['corrAddrs'];
    maritalStatus = json['maritalStatus'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['corrPinCode'] = corrPinCode;
    data['depoName'] = depoName;
    data['permAddrs'] = permAddrs;
    data['gender'] = gender;
    data['exc'] = exc;
    data['mobNo'] = mobNo;
    data['corrCountry'] = corrCountry;
    data['permState'] = permState;
    data['email'] = email;
    data['mtf'] = mtf;
    data['fathOrHusName'] = fathOrHusName;
    data['corrCity'] = corrCity;
    data['dematAccNo'] = dematAccNo;
    data['depoParticipant'] = depoParticipant;
    data['dpId'] = dpId;
    data['panNumber'] = panNumber;
    data['corrState'] = corrState;
    data['dob'] = dob;
    data['permCountry'] = permCountry;
    data['name'] = name;
    data['permCity'] = permCity;
    data['taxResidence'] = taxResidence;
    data['permPinCode'] = permPinCode;
    data['corrAddrs'] = corrAddrs;
    data['maritalStatus'] = maritalStatus;
    return data;
  }
}
