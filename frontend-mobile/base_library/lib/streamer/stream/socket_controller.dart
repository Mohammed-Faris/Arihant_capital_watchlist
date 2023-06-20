import 'dart:async';
import 'dart:io';

import '../../utils/config/log_config.dart';
import '../../utils/config/streamer_config.dart';
import '../../utils/constants/lib_constants.dart';
import 'streaming_manager.dart';

class SocketController {
  SocketController._internal();

  static SocketController? _instance;

  factory SocketController() {
    _instance ??= SocketController._internal();

    return _instance!;
  }

  bool isConnectionClosed = false;
  Timer? reconnectFunc;
  StreamSubscription? socketListener;

  Socket? socket;

  Future<void> initSocket() async {
    String hostUrl = StreamerConfig.socketHostUrl;
    int hostPort = StreamerConfig.socketHostPort;
    Duration timeout = StreamerConfig.socketTimeout;
    try {
      isConnectionClosed = false;
      if (StreamerConfig.socketMode == SocketMode.TLS) {
        socket =
            await SecureSocket.connect(hostUrl, hostPort, timeout: timeout);
      } else {
        socket = await Socket.connect(hostUrl, hostPort, timeout: timeout);
      }
      await socketListener?.cancel();

      socketListener = socket?.listen(
        onData,
        onError: _onError,
        onDone: _onDone,
      );
      StreamingManager().onResumed();
    } catch (e) {
      LogConfig().printLog('catchError $e');
      reconnection();
    }
  }

  void requestSocket(String request) {
    if (socket != null && !isConnectionClosed) {
      LogConfig().printLog('request $request');
      socket?.write(request);
    }
  }

  Future<void> onData(data) async {
    StreamingManager().onMessageRecv(data);
  }

  void _onError(dynamic error, StackTrace trace) {
    LogConfig().printLog('_onError $_onError');
  }

  void _onDone() {
    socket?.destroy();
    if (!isConnectionClosed) {
      reconnection();
    }
  }

  void close() {
    isConnectionClosed = true;
    socket?.close();
    socket?.destroy();
    socketListener?.cancel();
    socket = null;
  }

  void reconnection() {
    if (isConnectionClosed) {
      return;
    }
    reconnectFunc?.cancel();
    reconnectFunc = Timer(StreamerConfig.socketTimeout, () {
      initSocket();
    });
  }
}
