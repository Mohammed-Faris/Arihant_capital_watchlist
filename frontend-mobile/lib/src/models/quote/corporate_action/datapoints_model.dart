import 'data_point_base.dart';

class DataPoints {
  List<DataPointBase> dataPoints = [];

  DataPoints({dataPoints});

  getDataPoints() {
    return dataPoints;
  }

  setDataPoints(List<DataPointBase> points) {
    dataPoints = points;
  }

  addDataPoint(DataPointBase dataPoint) {
    dataPoints.add(dataPoint);
  }
}
