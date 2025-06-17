import 'package:flutter/material.dart';
import 'package:lie_and_truth/utils.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionHandler {
  PermissionHandler._();

  static final PermissionHandler _instance = PermissionHandler._();

  factory PermissionHandler() => _instance;

  bool isPermanentlyDenied = false;

  // make group of permission
  // group 1: [storage, camera, location , microphone , call , bluetooth_scan ]
  final List<Permission> _permissions = [
    // Permission.storage,
    Permission.camera,
    Permission.microphone,
  ];

  // request permission for [storage, camera, location , microphone , call , bluetooth_scan ]

  Future<bool> requestAllPermissionsFromList() async {
    Utils.debug('requestAllPermissions');
    final Map<Permission, PermissionStatus> permissions =
    await _permissions.request();
    Utils.debug('permissions: $permissions');

    isPermanentlyDenied = false;

    // check if all permissions are granted
    if (permissions.values.every((element) => element.isGranted)) {
      return true;
    }

    // check if any permission is permanently denied
    if (permissions.values.any((element) => element.isPermanentlyDenied)) {
      isPermanentlyDenied = true;
      return false;
    }

    return false;
  }

  Future<bool> onlyCheckUserHavePermissionsOrNot() async {
    // check if all permissions are granted
    if (await _permissions.first.status.isGranted &&
        await _permissions.last.status.isGranted) {
      return true;
    }
    return false;
  }

// dialog
  void showPermissionDialog(BuildContext context) {
    Utils.debug('_showPermissionDialog');
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          AlertDialog(
            title: Text('Permission Required'),
            content: Text('Do you want to record video prank?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  if (isPermanentlyDenied) {
                    Navigator.pop(context);
                    await openAppSettings();
                  } else {
                    if (await requestAllPermissionsFromList()) {} else {

                    }
                    Navigator.pop(context);
                  }
                },
                child: Text('Ok'),
              ),
            ],
          ),
    );
  }
}
