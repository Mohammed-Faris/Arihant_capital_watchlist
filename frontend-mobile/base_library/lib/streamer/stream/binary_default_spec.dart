import 'dart:typed_data';
import 'package:intl/intl.dart';

import '../../utils/constants/lib_constants.dart';

Map pktTYPE = {49: StreamLevel.quote, 50: StreamLevel.quote2};

Map defaultPktINFO = {
  'PKT_SPEC': {
    49: {
      65: {'type': 'string', 'key': 'symbol', 'len': 20},
      66: {'type': 'uint8', 'key': 'precision', 'len': 1},
      67: {
        'type': 'float',
        'key': 'ltp',
        'len': 8,
        'fmt': (v, p) => commaFmt(v, precision: p)
      },
      68: {
        'type': 'float',
        'key': 'open',
        'len': 8,
        'fmt': (v, p) => commaFmt(v, precision: p)
      },
      69: {
        'type': 'float',
        'key': 'high',
        'len': 8,
        'fmt': (v, p) => commaFmt(v, precision: p)
      },
      70: {
        'type': 'float',
        'key': 'low',
        'len': 8,
        'fmt': (v, p) => commaFmt(v, precision: p)
      },
      71: {
        'type': 'float',
        'key': 'close',
        'len': 8,
        'fmt': (v, p) => commaFmt(v, precision: p)
      },
      72: {
        'type': 'float',
        'key': 'chng',
        'len': 8,
        'fmt': (v, p) => commaFmt(v, precision: p)
      },
      73: {
        'type': 'float',
        'key': 'chngPer',
        'len': 8,
        'fmt': (v, p) => commaFmt(v, precision: 2)
      },
      74: {
        'type': 'float',
        'key': 'atp',
        'len': 8,
        'fmt': (v, p) => commaFmt(v, precision: p)
      },
      75: {
        'type': 'float',
        'key': 'yHigh',
        'len': 8,
        'fmt': (v, p) => commaFmt(v, precision: p)
      },
      76: {
        'type': 'float',
        'key': 'yLow',
        'len': 8,
        'fmt': (v, p) => commaFmt(v, precision: p)
      },
      77: {
        'type': 'int32',
        'key': 'ltq',
        'len': 4,
        'fmt': (v, p) => commaFmt(v, precision: 0)
      },
      78: {
        'type': 'int32',
        'key': 'vol',
        'len': 4,
        'fmt': (v, p) => commaFmt(v, precision: 0)
      },
      79: {
        'type': 'float',
        'key': 'ttv',
        'len': 8,
        'fmt': (v, p) => commaFmt(v, precision: p)
      },
      80: {
        'type': 'float',
        'key': 'ucl',
        'len': 8,
        'fmt': (v, p) => commaFmt(v, precision: p)
      },
      81: {
        'type': 'float',
        'key': 'lcl',
        'len': 8,
        'fmt': (v, p) => commaFmt(v, precision: p)
      },
      82: {
        'type': 'int32',
        'key': 'OI',
        'len': 4,
        'fmt': (v, p) => commaFmt(v, precision: 0)
      },
      83: {
        'type': 'float',
        'key': 'OIChngPer',
        'len': 8,
        'fmt': (v, p) => commaFmt(v, precision: 2)
      },
      84: {
        'type': 'int32',
        'key': 'ltt',
        'len': 4,
        'fmt': (v, p) => dateFmt(v),
      },
      87: {
        'type': 'float',
        'key': 'bidPrice',
        'len': 8,
        'fmt': (v, p) => commaFmt(v, precision: p)
      },
      90: {
        'type': 'float',
        'key': 'askPrice',
        'len': 8,
        'fmt': (v, p) => commaFmt(v, precision: p)
      },
    },
    50: {
      65: {'type': 'string', 'key': 'symbol', 'len': 20},
      66: {'type': 'uint8', 'key': 'precision', 'len': 1},
      85: {
        'type': 'int32',
        'key': 'totBuyQty',
        'len': 4,
        'fmt': (v, p) => commaFmt(v, precision: 0)
      },
      86: {
        'type': 'int32',
        'key': 'totSellQty',
        'len': 4,
        'fmt': (v, p) => commaFmt(v, precision: 0)
      },
      //BID
      87: {
        'type': 'float',
        'key': 'price',
        'len': 8,
        'fmt': (v, p) => commaFmt(v, precision: p)
      },
      88: {
        'type': 'int32',
        'key': 'qty',
        'len': 4,
        'fmt': (v, p) => commaFmt(v, precision: 0)
      },
      89: {
        'type': 'int32',
        'key': 'no',
        'len': 4,
        'fmt': (v, p) => commaFmt(v, precision: 0)
      },
      //ASK
      90: {
        'type': 'float',
        'key': 'price',
        'len': 8,
        'fmt': (v, p) => commaFmt(v, precision: p)
      },
      91: {
        'type': 'int32',
        'key': 'qty',
        'len': 4,
        'fmt': (v, p) => commaFmt(v, precision: 0)
      },
      92: {
        'type': 'int32',
        'key': 'no',
        'len': 4,
        'fmt': (v, p) => commaFmt(v, precision: 0)
      },
      93: {
        'type': 'uint8',
        'key': 'nDepth',
        'len': 1,
      },
    },
  },
  'BID_ASK_OBJ_LEN': 3
};

String commaFmt(dynamic value, {int precision = 2}) {
  double v = double.parse(value.toString());

  String data =
      NumberFormat.currency(locale: 'hi', name: '', decimalDigits: precision)
          .format(v)
          .toString();
  return data;
}

String ab2str(Uint8List buf, int offset, int length) {
  final Uint8List list = Uint8List.sublistView(buf, offset, offset + length);
  String s = String.fromCharCodes(list);
  return s.replaceAll('\u0000', '');
}

String dateFmt(value) {
  if (value == null) return value;
  value = int.parse(value) * 1000;
  List<String> month = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'June',
    'July',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];

  final DateTime dateValue = DateTime.fromMillisecondsSinceEpoch(value);
  int dd = dateValue.day;
  final int mm = dateValue.month - 1;
  final int yyyy = dateValue.year;

  String time = DateFormat.Hms().format(dateValue);
  String date = (dd < 10 ? ('0$dd') : dd).toString();

  final String fullDate = '$date ${month[mm]} $yyyy , $time';

  return fullDate;
}
