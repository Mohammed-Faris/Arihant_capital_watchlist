// ignore_for_file: constant_identifier_names

class DataPointBase {
  DataPointType? type;
  DataPointBase({this.type});

  getDataPointType() {
    return type;
  }
}

enum DataPointType {
  DIVIDEND,
  BONUS,
  RIGHTS,
  SPLITS,
}
