import 'dart:async';

import 'package:flutter/services.dart';

enum InstallStatus {
  unknown(0),
  pending(1),
  downloading(2),
  installing(3),
  installed(4),
  failed(5),
  canceled(6),
  downloaded(11);

  const InstallStatus(this.value);
  final int value;
}

enum UpdateAvailability {
  unknown(0),
  updateNotAvailable(1),
  updateAvailable(2),
  developerTriggeredUpdateInProgress(3);

  const UpdateAvailability(this.value);
  final int value;
}

enum AppUpdateResult {
  success,
  userDeniedUpdate,
  inAppUpdateFailed,
}

class InAppUpdate {
  static const MethodChannel _channel = MethodChannel('in_app_update');

  static Future<AppUpdateInfo> checkForUpdate() async {
    final result = await _channel.invokeMethod('checkForUpdate');

    return AppUpdateInfo(
      updateAvailability: UpdateAvailability.values.firstWhere(
          (element) => element.value == result['updateAvailability']),
      immediateUpdateAllowed: result['immediateAllowed'],
      flexibleUpdateAllowed: result['flexibleAllowed'],
      availableVersionCode: result['availableVersionCode'],
      installStatus: InstallStatus.values
          .firstWhere((element) => element.value == result['installStatus']),
      packageName: result['packageName'],
      clientVersionStalenessDays: result['clientVersionStalenessDays'],
      updatePriority: result['updatePriority'],
    );
  }

  static Future<AppUpdateResult> performImmediateUpdate() async {
    try {
      await _channel.invokeMethod('performImmediateUpdate');
      return AppUpdateResult.success;
    } on PlatformException catch (e) {
      if (e.code == 'USER_DENIED_UPDATE') {
        return AppUpdateResult.userDeniedUpdate;
      } else if (e.code == 'IN_APP_UPDATE_FAILED') {
        return AppUpdateResult.inAppUpdateFailed;
      }

      rethrow;
    }
  }

  static Future<AppUpdateResult> startFlexibleUpdate() async {
    try {
      await _channel.invokeMethod('startFlexibleUpdate');
      return AppUpdateResult.success;
    } on PlatformException catch (e) {
      if (e.code == 'USER_DENIED_UPDATE') {
        return AppUpdateResult.userDeniedUpdate;
      } else if (e.code == 'IN_APP_UPDATE_FAILED') {
        return AppUpdateResult.inAppUpdateFailed;
      }

      rethrow;
    }
  }

  static Future<void> completeFlexibleUpdate() async {
    return await _channel.invokeMethod('completeFlexibleUpdate');
  }
}

class AppUpdateInfo {
  final UpdateAvailability updateAvailability;

  final bool immediateUpdateAllowed;

  final bool flexibleUpdateAllowed;

  final int? availableVersionCode;

  final InstallStatus installStatus;

  final String packageName;

  final int updatePriority;

  final int? clientVersionStalenessDays;

  AppUpdateInfo({
    required this.updateAvailability,
    required this.immediateUpdateAllowed,
    required this.flexibleUpdateAllowed,
    required this.availableVersionCode,
    required this.installStatus,
    required this.packageName,
    required this.clientVersionStalenessDays,
    required this.updatePriority,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppUpdateInfo &&
          runtimeType == other.runtimeType &&
          updateAvailability == other.updateAvailability &&
          immediateUpdateAllowed == other.immediateUpdateAllowed &&
          flexibleUpdateAllowed == other.flexibleUpdateAllowed &&
          availableVersionCode == other.availableVersionCode &&
          installStatus == other.installStatus &&
          packageName == other.packageName &&
          clientVersionStalenessDays == other.clientVersionStalenessDays &&
          updatePriority == other.updatePriority;

  @override
  int get hashCode =>
      updateAvailability.hashCode ^
      immediateUpdateAllowed.hashCode ^
      flexibleUpdateAllowed.hashCode ^
      availableVersionCode.hashCode ^
      installStatus.hashCode ^
      packageName.hashCode ^
      clientVersionStalenessDays.hashCode ^
      updatePriority.hashCode;

  @override
  String toString() =>
      'InAppUpdateState{updateAvailability: $updateAvailability, '
      'immediateUpdateAllowed: $immediateUpdateAllowed, '
      'flexibleUpdateAllowed: $flexibleUpdateAllowed, '
      'availableVersionCode: $availableVersionCode, '
      'installStatus: $installStatus, '
      'packageName: $packageName, '
      'clientVersionStalenessDays: $clientVersionStalenessDays, '
      'updatePriority: $updatePriority}';
}
