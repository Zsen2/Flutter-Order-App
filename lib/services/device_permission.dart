import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Permission Example'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            bool storagePermissionGranted = await requestStoragePermission();
            if (storagePermissionGranted) {
              print('Storage permission granted');
            } else {
              print('Storage permission denied');
            }
          },
          child: const Text('Request Storage Permission'),
        ),
      ),
    );
  }

  Future<bool> requestStoragePermission() async {
    PermissionStatus status = await Permission.storage.request();
    return status == PermissionStatus.granted;
  }
}

void main() {
  runApp(MaterialApp(
    home: PermissionWidget(),
  ));
}
