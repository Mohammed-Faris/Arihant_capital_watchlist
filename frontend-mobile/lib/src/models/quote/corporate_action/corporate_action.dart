import 'datapoints_model.dart';

class CorporateAction {
  String msg = "";
  DataPoints dataPoints = DataPoints();

  CorporateAction(msg, dataPoints);

  CorporateAction.fromJson();
}
