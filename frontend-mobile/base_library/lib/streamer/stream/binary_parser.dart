// ignore_for_file: unnecessary_null_comparison

import 'dart:typed_data';
import 'package:archive/archive_io.dart';
import '../../utils/config/log_config.dart';
import '../../utils/constants/lib_constants.dart';
import '../models/binary_spec_matrix_model.dart';
import 'binary_default_spec.dart';
import 'streaming_manager.dart';

class BinaryParser {
  Function cb;
  Uint8List binaryData = Uint8List.fromList([]);

  BinaryParser(this.cb);

  void setBinaryData(Uint8List data) {
    binaryData = Uint8List.fromList(binaryData + data);
    process();
  }

  void resetBinary() {
    binaryData = Uint8List.fromList([]);
  }

  void process() {
    if (binaryData.length > 5) {
      final ByteData bufferData = ByteData.view(binaryData.buffer);
      final int length = bufferData.getInt32(0, Endian.host);
      final int compressionAlgo = bufferData.getInt8(4);
      if (binaryData.length >= length) {
        try {
          final Uint8List singleBinaryPacketData =
              binaryData.sublist(5, length);
          if (compressionAlgo == 10) {
            decompressZLib(singleBinaryPacketData);
          } else {
            processDecomData(singleBinaryPacketData);
          }
          binaryData = binaryData.sublist(length);
          process();
        } catch (e) {
          print('Packet Split Error: ${e.toString()}');
        }
      }
    }
  }

  void decompressZLib(Uint8List data) {
    try {
      final Uint8List unCompressedSocketData =
          Uint8List.fromList(ZLibDecoder().decodeBytes(data));
      processDecomData(unCompressedSocketData);
    } catch (e) {
      LogConfig().printLog('Decompression Error $e');
    }
  }

  Future<void> processDecomData(Uint8List data) async {
    int length = data.length;
    for (int i = 0; i < length;) {
      final int lastProcLen = decodePKT(data.sublist(i));
      if (lastProcLen <= 0) {
        LogConfig()
            .printLog('Packet Length is wrong exiting the loop $lastProcLen');
        break;
      }
      i += lastProcLen;
    }
  }

  int decodePKT(Uint8List data) {
    final ByteData dv = ByteData.view(data.buffer);
    final int pktLen = dv.getInt16(0, Endian.host); // Includes pktType length

    final int pktType = dv.getInt8(2);

    final Map specMatrix = StreamingManager().pktInfo['PKT_SPEC'][pktType];
    if (specMatrix == null) {
      LogConfig().printLog('Unknown PktType $pktType');
      return pktLen;
    }
    String packetType = pktTYPE[pktType];

    Map? jData;

    if (packetType == StreamLevel.quote) {
      jData = decodeL1PKT(specMatrix, pktLen, dv, data);
    } else if (packetType == StreamLevel.quote2) {
      jData = decodeL2PKT(specMatrix, pktLen, dv, data);
    }
    if (jData == null) {
      return pktLen;
    }
    Map response = {};
    response['data'] = jData;
    response['streaming_type'] = packetType;
    Map<String, dynamic> r = {};
    r['response'] = response;
    cb(r);
    return pktLen;
  }

  Map? decodeL1PKT(Map specMatrix, int pktLen, ByteData dv, Uint8List data) {
    Map rawData = {};
    int precision = 2;

    for (int i = 3; i < pktLen;) {
      final int pktKey = dv.getInt8(i);
      i += 1;

      final Map<String, dynamic>? jsonSpec = specMatrix[pktKey];
      if (jsonSpec == null) {
        LogConfig().printLog('Unknown Pkt spec breaking $pktKey');
        return null;
      }

      BinarySpecMatrixModel spec = BinarySpecMatrixModel.fromJson(jsonSpec);
      if (spec.type == 'string') {
        dynamic v = ab2str(data, i, spec.len);
        rawData[spec.key] = [spec, v];
      } else if (spec.type == 'float') {
        dynamic v = dv.getFloat64(i, Endian.host);
        rawData[spec.key] = [spec, v];
      } else if (spec.type == 'int32') {
        dynamic v = dv.getInt32(i, Endian.host);
        rawData[spec.key] = [spec, v];
      } else if (spec.type == 'uint8') {
        dynamic v = dv.getInt8(i);
        if (spec.key == 'precision')
          precision = v;
        else
          rawData[spec.key] = [spec, v];
      }

      i += spec.len;
    }

    Map jData = {};

    for (var key in rawData.keys) {
      if (rawData.containsKey(key)) {
        final BinarySpecMatrixModel spec = rawData[key][0];
        dynamic value = rawData[key][1].toString();
        jData[key] = spec.fmt != null ? spec.fmt!(value, precision) : value;
      }
    }
    return jData;
  }

  Map? decodeL2PKT(Map specMatrix, int pktLen, ByteData dv, Uint8List data) {
    int precision = 2;
    int noLevel = 0;
    final List bids = [];
    final List asks = [];
    List? list;
    Map lObj = Map();
    Map rawData = Map();
    for (int i = 3; i < pktLen;) {
      int pktKey = dv.getInt8(i);
      i += 1;
      final Map<String, dynamic>? jsonSpec = specMatrix[pktKey];

      if (jsonSpec == null) {
        LogConfig().printLog('Unknown Pkt spec breaking $pktKey');
        return null;
      }

      BinarySpecMatrixModel spec = BinarySpecMatrixModel.fromJson(jsonSpec);
      if (spec.type == 'string') {
        rawData[spec.key] = [spec, ab2str(data, i, spec.len)];
      } else if (spec.type == 'float') {
        double v = dv.getFloat64(i, Endian.host);
        if (list != null)
          lObj[spec.key] = spec.fmt != null ? spec.fmt!(v, precision) : v;
        else
          rawData[spec.key] = [spec, v];
      } else if (spec.type == 'int32') {
        int v = dv.getInt32(i, Endian.host);
        if (list != null)
          lObj[spec.key] = spec.fmt != null ? spec.fmt!(v, precision) : v;
        else
          rawData[spec.key] = [spec, v];
      } else if (spec.type == 'uint8') {
        int v = dv.getInt8(i);
        if (spec.key == 'nDepth') {
          noLevel = v;
          // Once the no_level receives, then
          // next packet will be list sequence of bids
          // So assigning the list state as bids.
          list = bids;
        } else if (spec.key == 'precision') {
          precision = v;
        } else {
          rawData[spec.key] = [spec, v];
        }
      }
      i += spec.len;

      if (list != null) {
        if (lObj.keys.length == StreamingManager().pktInfo['BID_ASK_OBJ_LEN']) {
          // Once 'price', 'qty' and 'no-orders', these 3 items are received in this iteration
          // pushing the object to the current list, and creating a new object for the next set.
          list.add(lObj);
          lObj = {};
        }
        // Once the list size reaches the desired length, means all bids are received.
        // then assigning new state 'ask' to the list, which will be container
        // for next set of packets.
        if (noLevel == list.length) {
          list = asks;
        }
      }
    }

    Map jData = {};
    for (String key in rawData.keys) {
      if (rawData.containsKey(key)) {
        final BinarySpecMatrixModel spec = rawData[key][0];
        dynamic value = rawData[key][1];
        jData[key] =
            spec.fmt != null ? spec.fmt!(value, precision) : value.toString();
      }
    }
    jData['bid'] = bids;
    jData['ask'] = asks;
    return jData;
  }
}
