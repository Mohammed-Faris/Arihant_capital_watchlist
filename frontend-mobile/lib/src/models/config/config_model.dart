// ignore_for_file: overridden_fields, annotate_overrides

import 'package:acml/src/config/app_config.dart';
import 'package:acml/src/constants/app_constants.dart';
import 'package:acml/src/models/common/sym_model.dart';
import 'package:acml/src/models/common/symbols_model.dart';
import 'package:acml/src/models/config/suggested_stocks_model.dart';
import 'package:acml/src/models/sort_filter/sort_filter_model.dart';
import 'package:msil_library/models/base/base_model.dart';
import 'package:msil_library/utils/config/streamer_config.dart';

class ConfigModel extends BaseModel {
  Indices? indices;
  String? watchlistGroupLimit;
  Map? precision;
  String? watchlistSymLimit;
  WebQuotes? webQuotes;
  String? chartUrl;
  String? poaLink;
  String? needHelpUrl;
  String? signUpUrl;
  // ignore: non_constant_identifier_names
  ChartTimings? chartTiming_v2;
  String? lineChartUrl;
  VersionDetail? versionDetail;
  List<SuggestedStocks>? suggestedStocks;
  List<PredefinedWatch>? predefinedWatch;
  List<AmoMktTimings>? amoMktTimings;
  List<AmoandMarketTimings>? amoandMktTimings;
  String? gtdTiming;

  Map<String, dynamic>? quoteTabs = {};
  Map<String, dynamic>? overviewTab = {};
  List<dynamic>? boUrls = [];
  ArhtBnkDtls? arhtBnkDtls;
  String? referUrl;
  Map<String, dynamic>? chartTiming;
  String? marginCalculatorUrl;
  List? holidays = [];
  int refreshTime = 0;
  Map<String, dynamic>? maintenance;
  String? callforTrade;
  ConfigModel(
      {required this.indices,
      required this.watchlistGroupLimit,
      required this.precision,
      required this.watchlistSymLimit,
      required this.webQuotes,
      required this.chartUrl,
      required this.poaLink,
      required this.quoteTabs,
      required this.lineChartUrl,
      required this.marginCalculatorUrl,
      required this.overviewTab,
      required this.referUrl,
      required this.needHelpUrl,
      required this.signUpUrl,
      required this.versionDetail,
      required this.suggestedStocks,
      required this.predefinedWatch,
      this.callforTrade,
      this.arhtBnkDtls,
      required this.holidays});

  ConfigModel.fromJson(Map<String, dynamic> json) : super.fromJSON(json) {
    indices =
        data['indices'] != null ? Indices.fromJson(data['indices']) : null;
    watchlistGroupLimit = data['watchlistGroupLimit'];
    precision = data['precision'];
    watchlistSymLimit = data['watchlistSymLimit'];
    marginCalculatorUrl = data['marginCalculator'];
    chartUrl = data['chartUrl'];
    poaLink = data['poaLink'];
    needHelpUrl = data['needHelpUrl'];
    chartTiming = data['chartTiming'];
    signUpUrl = data['signUpUrl'];
    boUrls = data['boUrls'];
    maintenance = data['maintenance'];
    quoteTabs = data['quoteTabs'];
    lineChartUrl = data['lineChart'];
    gtdTiming = data["gtdValidity"] ?? "9:00-04:30";
    Featureflag.setOtpExpiry =
        int.tryParse(data['enableFeatures']?["setOtpExpiry"] ?? "0") ?? 0;
    Featureflag.showOverallPnl =
        data['enableFeatures']?['showOverallPnlPosition'] ?? false;
    Featureflag.showOverallPnl =
        data['enableFeatures']?['showOverallPnlPosition'] ?? false;
    Featureflag.coverOder = data['enableFeatures']?['coverOrder'] ?? false;
    Featureflag.bracketOder =
        data['enableFeatures']?['bracketOrder_V2'] ?? false;
    Featureflag.nomineeCampaign =
        data['enableFeatures']?['nomineeCampaign'] ?? false;
    Featureflag.campaignEndDate =
        data['enableFeatures']?['campaignEndDate'] ?? "31st Mar";
    // try {
    //   Featureflag.lastUpdatedTime = DateTime.tryParse(
    //           data['enableFeatures']?['lastUpdatedTimeOfCampaign']) ??
    //       DateTime.now();
    //   RemoteConfigService.reinitialize(
    //       Featureflag.lastUpdatedTime ?? DateTime.now());
    // } catch (e) {
    //   Featureflag.lastUpdatedTime = DateTime.now();
    //   RemoteConfigService.reinitialize(
    //       Featureflag.lastUpdatedTime ?? DateTime.now());
    // }
    Featureflag.mcxBo = data['enableFeatures']?['enableMcxBO'] ?? false;
    Featureflag.cdsBo = data['enableFeatures']?['enableCdsBO'] ?? false;
    Featureflag.cdsCo = data['enableFeatures']?['enableCdsCO'] ?? false;

    Featureflag.mcxGtd = data['enableFeatures']?['enableMcxGtd'] ?? false;
    Featureflag.isMultiplierCds =
        data['enableFeatures']?['isMultiplierCds'] ?? true;
    Featureflag.isMultiplierMcx =
        data['enableFeatures']?['isMultiplieMcx'] ?? false;
    Featureflag.isCheckSegmentsFromBo =
        data['enableFeatures']?['isCheckSegmentsFromBo'] ?? false;

    if (AppConfig.flavor == "cug") {
      StreamerConfig.socketHostUrl = data['enableFeatures']?['socketHostUrl'] ??
          StreamerConfig.socketHostUrl.trim();
    }
    Featureflag.gTD = data['enableFeatures']?['gtdOrder_V2'] ?? false;
    Featureflag.csToggle = data['enableFeatures']?['csToggle_V2'] ?? false;
    Featureflag.isActualCFPrice =
        data['enableFeatures']?['cfActualPrice'] ?? false;
    Featureflag.isFnoSymbolsKeyCheck =
        data['enableFeatures']?['isFnoSymbolsKeyValidate'] ?? false;
    Featureflag.showCharges = data['enableFeatures']?['showCharges'] ?? false;
    Featureflag.boSecondLegType =
        data['enableFeatures']?['boSecondLegType'] ?? AppConstants.limit;
    Featureflag.sessionValidation =
        data['enableFeatures']?['sessionValidation'] ?? false;
    // Featureflag.fetchOrderfromSocket =
    //     data['enableFeatures']?['fetchOrderfromSocket'] ?? false;
    refreshTime = int.tryParse(data['refreshTime'] ?? "0") ?? 0;
    referUrl = data["referUrl"];
    overviewTab = data['overviewTab'];
    holidays = data["holidayList"];
    callforTrade = data["callForTrade"] ?? "";
    if (data['chartUpdatedTiming'] != null) {
      chartTiming_v2 = ChartTimings.fromJson(data['chartUpdatedTiming']);
    }
    versionDetail = data['versionDetail'] != null
        ? VersionDetail.fromJson(data['versionDetail'])
        : null;
    if (data['suggestedStocks'] != null) {
      suggestedStocks = <SuggestedStocks>[];
      data['suggestedStocks'].forEach((v) {
        suggestedStocks!.add(SuggestedStocks.fromJson(v));
      });
    }
    if (data['predefinedWatch_new'] != null) {
      predefinedWatch = <PredefinedWatch>[];
      data['predefinedWatch_new'].forEach((v) {
        predefinedWatch!.add(PredefinedWatch.fromJson(v));
      });
    }
    if (data['amoAndMktTmgs'] != null) {
      amoandMktTimings = <AmoandMarketTimings>[];
      data['amoAndMktTmgs'].forEach((v) {
        amoandMktTimings!.add(AmoandMarketTimings.fromJson(v));
      });
    }
    if (data['amoMktTimings'] != null) {
      amoMktTimings = <AmoMktTimings>[];
      data['amoMktTimings'].forEach((v) {
        amoMktTimings!.add(AmoMktTimings.fromJson(v));
      });
    }
    arhtBnkDtls = data['arhtBnkDtls'] != null
        ? ArhtBnkDtls.fromJson(data['arhtBnkDtls'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    // data['indices'] = indices!.toJson();
    data['watchlistGroupLimit'] = watchlistGroupLimit;
    data['precision'] = precision;
    data['watchlistSymLimit'] = watchlistSymLimit;
    // data['webQuotes'] = webQuotes.toJson();
    data['chartUrl'] = chartUrl;
    data['lineChart'] = lineChartUrl;

    data['poaLink'] = poaLink;
    data['needHelpUrl'] = needHelpUrl;
    data['signUpUrl'] = signUpUrl;
    data['versionDetail'] = versionDetail;
    data['quoteTabs'] = quoteTabs;
    data['overviewTab'] = overviewTab;
    data['marginCalculator'] = marginCalculatorUrl;
    data['suggestedStocks'] = suggestedStocks;
    data['predefinedWatch'] = predefinedWatch;
    data['gtdValidity'] = gtdTiming;
    if (amoMktTimings != null) {
      data['amoMktTimings'] = amoMktTimings!.map((v) => v.toJson()).toList();
    }
    if (amoandMktTimings != null) {
      data['amoAndMktTmgs'] = amoandMktTimings!.map((v) => v.toJson()).toList();
    }
    if (arhtBnkDtls != null) {
      data['arhtBnkDtls'] = arhtBnkDtls!.toJson();
    }
    return data;
  }
}

class ArhtBnkDtls {
  List<Banks>? banks;
  String? contact;
  String? secContact;

  ArhtBnkDtls({this.banks, this.contact});

  ArhtBnkDtls.fromJson(Map<String, dynamic> json) {
    if (json['banks'] != null) {
      banks = <Banks>[];
      json['banks'].forEach((v) {
        banks!.add(Banks.fromJson(v));
      });
    }
    contact = json['contact'];
    secContact = json["secContact"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (banks != null) {
      data['banks'] = banks!.map((v) => v.toJson()).toList();
    }
    data['contact'] = contact;
    return data;
  }
}

class Banks {
  String? accNo;
  String? bankName;
  String? accType;
  String? ifscCode;
  String? benefName;

  Banks(
      {this.accNo, this.bankName, this.accType, this.ifscCode, this.benefName});

  Banks.fromJson(Map<String, dynamic> json) {
    accNo = json['accNo'];
    bankName = json['bankName'];
    accType = json['accType'];
    ifscCode = json['ifscCode'];
    benefName = json['benefName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['accNo'] = accNo;
    data['bankName'] = bankName;
    data['accType'] = accType;
    data['ifscCode'] = ifscCode;
    data['benefName'] = benefName;
    return data;
  }
}

class AmoMktTimings {
  String? amoEndTime;
  String? mktStartTime;
  String? exc;
  String? mktEndTime;
  String? amoStartTime;

  AmoMktTimings(
      {this.amoEndTime,
      this.mktStartTime,
      this.exc,
      this.mktEndTime,
      this.amoStartTime});

  AmoMktTimings.fromJson(Map<String, dynamic> json) {
    amoEndTime = json['amoEndTime']?.replaceAll("--", "");
    mktStartTime = json['mktStartTime']?.replaceAll("--", "");
    exc = json['exc'];
    mktEndTime = json['mktEndTime']?.replaceAll("--", "");
    amoStartTime = json['amoStartTime']?.replaceAll("--", "");
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['amoEndTime'] = amoEndTime;
    data['mktStartTime'] = mktStartTime;
    data['exc'] = exc;
    data['mktEndTime'] = mktEndTime;
    data['amoStartTime'] = amoStartTime;
    return data;
  }
}

class Indices {
  List<NSE>? nSE;
  List<BSE>? bSE;

  Indices({this.nSE, this.bSE});

  Indices.fromJson(Map<String, dynamic> json) {
    if (json['NSE'] != null) {
      nSE = <NSE>[];
      json['NSE'].forEach((v) {
        nSE!.add(NSE.fromJson(v));
      });
    }
    if (json['BSE'] != null) {
      bSE = <BSE>[];
      json['BSE'].forEach((v) {
        bSE!.add(BSE.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (nSE != null) {
      data['NSE'] = nSE!.map((v) => v.toJson()).toList();
    }
    if (bSE != null) {
      data['BSE'] = bSE!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class BSE extends Symbols {
  String? dispSym;
  Sym? sym;
  String? baseSym;
  bool? hasFutOpt;

  BSE({this.dispSym, this.sym, this.baseSym, this.hasFutOpt});

  BSE.fromJson(Map<String, dynamic> json) {
    dispSym = json['dispSym'];
    sym = json['sym'] != null ? Sym.fromJson(json['sym']) : null;
    baseSym = json['baseSym'];
    hasFutOpt = json['hasFutOpt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['dispSym'] = dispSym;
    if (sym != null) {
      data['sym'] = sym!.toJson();
    }
    data['baseSym'] = baseSym;
    data['hasFutOpt'] = hasFutOpt;
    return data;
  }
}

class NSE extends Symbols {
  String? dispSym;
  Sym? sym;
  String? baseSym;
  bool? hasFutOpt;

  NSE({this.dispSym, this.sym, this.baseSym, this.hasFutOpt});

  NSE.fromJson(Map<String, dynamic> json) {
    dispSym = json['dispSym'];
    sym = json['sym'] != null ? Sym.fromJson(json['sym']) : null;
    baseSym = json['baseSym'];
    hasFutOpt = json['hasFutOpt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['dispSym'] = dispSym;
    if (sym != null) {
      data['sym'] = sym!.toJson();
    }
    data['baseSym'] = baseSym;
    data['hasFutOpt'] = hasFutOpt;
    return data;
  }
}

class AmoandMarketTimings {
  String? mktStartTime;
  String? exc;
  String? mktEndTime;
  List<String>? amotmngs;

  AmoandMarketTimings(
      {this.mktStartTime, this.exc, this.mktEndTime, this.amotmngs});

  AmoandMarketTimings.fromJson(Map<String, dynamic> json) {
    mktStartTime = json['mktStartTime'];
    exc = json['exc'];
    mktEndTime = json['mktEndTime'];
    amotmngs = json['amotmngs'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['mktStartTime'] = mktStartTime;
    data['exc'] = exc;
    data['mktEndTime'] = mktEndTime;
    data['amotmngs'] = amotmngs;
    return data;
  }
}

class WebQuotes {
  late List<String> nSE;
  late List<String> bSE;

  WebQuotes(this.nSE, this.bSE);

  WebQuotes.fromJson(Map<String, dynamic> json) {
    nSE = json['NSE'].cast<String>();
    bSE = json['BSE'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['NSE'] = nSE;
    data['BSE'] = bSE;
    return data;
  }
}

class ChartTimings {
  Equity? equity;
  Equity? currency;
  Equity? commodity;
  Equity? fno;
  Equity? indices;

  ChartTimings(
      {this.equity, this.currency, this.commodity, this.fno, this.indices});

  ChartTimings.fromJson(Map<String, dynamic> json) {
    equity = json['equity'] != null ? Equity.fromJson(json['equity']) : null;
    currency =
        json['currency'] != null ? Equity.fromJson(json['currency']) : null;
    commodity =
        json['commodity'] != null ? Equity.fromJson(json['commodity']) : null;
    fno = json['fno'] != null ? Equity.fromJson(json['fno']) : null;
    indices = json['indices'] != null ? Equity.fromJson(json['indices']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (equity != null) {
      data['equity'] = equity!.toJson();
    }
    if (currency != null) {
      data['currency'] = currency!.toJson();
    }
    if (commodity != null) {
      data['commodity'] = commodity!.toJson();
    }
    if (fno != null) {
      data['fno'] = fno!.toJson();
    }
    if (indices != null) {
      data['indices'] = indices!.toJson();
    }
    return data;
  }
}

class Equity {
  String? oneDayTmng;
  String? oneWeekTmng;

  Equity({this.oneDayTmng, this.oneWeekTmng});

  Equity.fromJson(Map<String, dynamic> json) {
    oneDayTmng = json['oneDayTmng'];
    oneWeekTmng = json['oneWeekTmng'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['oneDayTmng'] = oneDayTmng;
    data['oneWeekTmng'] = oneWeekTmng;
    return data;
  }
}

class PredefinedWatch {
  late String dispSym;
  late String baseSym;
  SortModel? selectedSortBy;
  bool isSortSelected = false;
  bool isfilterModel = false;
  List<FilterModel>? selectedFilter;
  PredefinedWatch(this.dispSym, this.baseSym);

  PredefinedWatch.fromJson(Map<String, dynamic> json) {
    dispSym = json['dispSym'];
    baseSym = json['baseSym'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['dispSym'] = dispSym;
    data['baseSym'] = baseSym;
    return data;
  }
}

class VersionDetail {
  late String appVersion;
  late String releaseNotes;
  late bool mandatory;
  late String url;

  VersionDetail(this.appVersion, this.releaseNotes, this.mandatory, this.url);

  VersionDetail.fromJson(Map<String, dynamic> json) {
    appVersion = json['appVersion'];
    releaseNotes = json['releaseNotes'];
    mandatory = json['mandatory'];
    url = json['url'];
  }
}
