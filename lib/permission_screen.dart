import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'unified_login_screen.dart';

class PermissionScreen extends StatefulWidget {
  const PermissionScreen({super.key});

  @override
  State<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen> {
  bool isChecking = true;

  @override
  void initState() {
    super.initState();
    requestPermissions();
  }

  Future<void> requestPermissions() async {
    setState(() => isChecking = true);

    await [
      Permission.location,
      Permission.camera,
      Permission.microphone,
      Permission.contacts,
    ].request();

    if (!mounted) return;

    bool allGranted = await Permission.location.isGranted &&
        await Permission.camera.isGranted &&
        await Permission.microphone.isGranted &&
        await Permission.contacts.isGranted;

    if (allGranted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const UnifiedLoginScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("All permissions are required.")),
      );
      setState(() => isChecking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: isChecking
            ? const Center(child: CircularProgressIndicator())
            : Center(
            child: ElevatedButton(
              onPressed: requestPermissions,
              child: const Text("Grant Permissions"),
            ),
            ),
        );
    }
}