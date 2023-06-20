import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';

import '../base/base_request.dart';

class InitRequest extends BaseRequest {
  Future<void> buildRequest(String appName, String appVersion,
      String androidChannelName, String iOSChannelName) async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    final bool androidOs = Platform.isAndroid;
    dynamic deviceInfoDetails;
    String osVersion;
    String modelName;
    if (androidOs) {
      deviceInfoDetails = await deviceInfo.androidInfo;
      osVersion = deviceInfoDetails.version.release as String;
      modelName = deviceInfoDetails.model;
    } else {
      deviceInfoDetails = await deviceInfo.iosInfo;
      osVersion = deviceInfoDetails.systemVersion as String;
      modelName = deviceInfoDetails.utsname.machine;
    }

    // This should be taken properly

    final String osType = androidOs ? 'Android' : 'IOS';
    final String osVendor = androidOs ? 'Google' : 'Apple';


    final String build = androidOs ? 'android-phone' : 'iphone';
    final String channel = androidOs ? androidChannelName : iOSChannelName;
    final Map<String, String> software = {
      'osType': osType,
      'osVendor': osVendor,
      'osName': osType,
      'osVersion': osVersion
    };

    final Map<String, String> app = {
      'version': appVersion,
      'name': appName,
      'channel': channel,
      'build': build
    };

    final Map<String, String> hardware = {
      'model': modelName,
    };

    addToData('software', software);
    addToData('app', app);
    addToData('hardware', hardware);
    addToData('network', <String, String>{});
  }
}
