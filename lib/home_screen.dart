import 'package:flutter/material.dart';
import 'priority_contacts_screen.dart';
import 'main.dart'; // Make sure ProfileScreen is defined there or imported properly

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isBackgroundEnabled = false;
  void toggleBackgroundService(bool value) {
    setState(() {
      isBackgroundEnabled = value;
    });

    if (isBackgroundEnabled) {
      startBackgroundService();
    } else {
      stopBackgroundService();
    }
  }

  void startBackgroundService() {
    // TODO: Add actual background service start logic here
    print("Background service started");
  }

  void stopBackgroundService() {
    // TODO: Add actual background service stop logic here
    print("Background service stopped");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Rapid Rescue")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              child: const Text("My Profile"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfileScreen()),
                );
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              child: const Text("Priority Contacts"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PriorityContactsScreen()),
                );
              },
            ),
            const SizedBox(height: 30),
            SwitchListTile(
              title: const Text("Enable Background Service"),
              value: isBackgroundEnabled,
              onChanged: toggleBackgroundService,
            ),
          ],
        ),
      ),
    );
  }
}
