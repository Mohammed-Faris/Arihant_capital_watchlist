import 'package:firebase_analytics/firebase_analytics.dart';
// import 'package:firebase_remote_config/firebase_remote_config.dart';

class FirebaseGlobal {
  static final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static final FirebaseAnalyticsObserver analyticsObserver =
      FirebaseAnalyticsObserver(analytics: analytics);
  // static FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.instance;
}
