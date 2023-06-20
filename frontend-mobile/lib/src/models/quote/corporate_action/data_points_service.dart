import '../../../constants/app_constants.dart';
import 'bonus_model.dart';
import 'data_point_base.dart';
import 'dividend_model.dart';
import 'quote_corporate_action_model.dart';
import 'rights_model.dart';
import 'splits_model.dart';

class DataPointsService {
  getAllDataPoints(QuoteCorporateActionModel? model) {
    List<DataPointBase> dataPoints = [];
    dataPoints.addAll(model!.bonus!.dataPoints.getDataPoints());
    dataPoints.addAll(model.rights!.dataPoints.getDataPoints());
    dataPoints.addAll(model.splits!.dataPoints.getDataPoints());
    dataPoints.addAll(model.dividend!.dataPoints.getDataPoints());
    return dataPoints;
  }

  List<String> getFilterList(QuoteCorporateActionModel? model) {
    List<String> filterList = [];
    filterList.add(AppConstants.all);
    if (model!.bonus!.dataPoints.getDataPoints() != null &&
        getBonus(model).isNotEmpty) {
      filterList.add(
        AppConstants.bonus,
      );
    }
    if (model.rights!.dataPoints.getDataPoints() != null &&
        getRights(model).isNotEmpty) {
      filterList.add(
        AppConstants.rights,
      );
    }
    if (model.splits!.dataPoints.getDataPoints() != null &&
        getSplits(model).isNotEmpty) {
      filterList.add(
        AppConstants.splits,
      );
    }
    if (model.dividend!.dataPoints.getDataPoints() != null &&
        getDividend(model).isNotEmpty) {
      filterList.add(
        AppConstants.dividend,
      );
    }
    if (filterList.length == 2) {
      filterList.removeAt(0);
    }
    return filterList;
  }

  List<DataPointBase> getDividend(QuoteCorporateActionModel? model) {
    return model!.dividend!.dataPoints.getDataPoints();
  }

  List<DataPointBase> getBonus(QuoteCorporateActionModel? model) {
    return model!.bonus!.dataPoints.getDataPoints();
  }

  List<DataPointBase> getSplits(QuoteCorporateActionModel? model) {
    return model!.splits!.dataPoints.getDataPoints();
  }

  List<DataPointBase> getRights(QuoteCorporateActionModel? model) {
    return model!.rights!.dataPoints.getDataPoints();
  }

  String getDividendMsg(QuoteCorporateActionModel? model) {
    return model!.dividend!.msg;
  }

  String getBonusMsg(QuoteCorporateActionModel? model) {
    return model!.bonus!.msg;
  }

  String getSplitsMsg(QuoteCorporateActionModel? model) {
    return model!.splits!.msg;
  }

  String getRightsMsg(QuoteCorporateActionModel? model) {
    return model!.rights!.msg;
  }

  getTypeAsString(DataPointType type) {
    switch (type) {
      case DataPointType.DIVIDEND:
        return "Dividend";
      case DataPointType.BONUS:
        return "Bonus";
      case DataPointType.SPLITS:
        return "Splits";
      case DataPointType.RIGHTS:
        return "Rights";
    }
  }

  getProperties(DataPointBase dataPoint, String key) {
    switch (dataPoint.type!) {
      case DataPointType.DIVIDEND:
        return (dataPoint as DividendDataPoint).toJson()[key] ?? '';
      case DataPointType.BONUS:
        return (dataPoint as BonusDataPoint).toJson()[key] ?? '';
      case DataPointType.SPLITS:
        return (dataPoint as SplitsDataPoint).toJson()[key] ?? '';
      case DataPointType.RIGHTS:
        return (dataPoint as RightsDataPoint).toJson()[key] ?? '';
    }
  }
}
