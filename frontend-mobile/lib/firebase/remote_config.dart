// import 'dart:convert';

// import 'package:firebase_crashlytics/firebase_crashlytics.dart';
// import 'package:firebase_remote_config/firebase_remote_config.dart';
// import 'package:flutter/material.dart';

// const String campaign = 'campaign';
// const String campaignImage = "campaignImage";

// class RemoteConfigService {
//   static Map<String, dynamic> get getCampaign =>
//       json.decode(_remoteConfig.getValue(campaign).asString());

//   static String get getCampaignImage =>
//       _remoteConfig.getValue(campaignImage).asString();
//   static final FirebaseRemoteConfig _remoteConfig =
//       FirebaseRemoteConfig.instance;

//   static final defaults = <String, dynamic>{
//     campaign: json.encode({"campaign": true, "subcampaign": false}),
//     campaignImage: ""
//   };
//   static Future reinitialize(DateTime time) async {
//     try {
//       if (_remoteConfig.lastFetchTime.compareTo(time) <= 0) {
//         await _remoteConfig.setConfigSettings(RemoteConfigSettings(
//           fetchTimeout: const Duration(seconds: 10),
//           minimumFetchInterval: const Duration(seconds: 10),
//         ));
//       } else {
//         await _remoteConfig.setConfigSettings(RemoteConfigSettings(
//           fetchTimeout: const Duration(seconds: 10),
//           minimumFetchInterval: const Duration(hours: 12),
//         ));
//       }
//       await _remoteConfig.setDefaults(defaults);

//       await _fetchAndActivate();
//     } catch (e) {
//       FirebaseCrashlytics.instance.recordFlutterError(
//         FlutterErrorDetails(
//           exception: e.toString(),
//         ),
//       );
//     }
//   }

//   static Future _fetchAndActivate() async {
//     await _remoteConfig.fetchAndActivate();
//   }
// }
