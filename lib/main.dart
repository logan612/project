import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'unified_login_screen.dart';
import 'permission_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const RapidRescueApp());
}

class RapidRescueApp extends StatelessWidget {
  const RapidRescueApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rapid Rescue',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.red),
      home: const PermissionScreen(),
    );
  }
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final addressController = TextEditingController();
  final dobController = TextEditingController();
  final mobileController = TextEditingController();
  final emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> saveProfile() async {
    final messenger = ScaffoldMessenger.of(context);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', nameController.text);
    await prefs.setString('user_age', ageController.text);
    await prefs.setString('user_address', addressController.text);
    await prefs.setString('user_dob', dobController.text);
    await prefs.setString('user_mobile', mobileController.text);
    await prefs.setString('user_email', emailController.text);

    if (!mounted) return;
    messenger.showSnackBar(
      const SnackBar(content: Text("Profile Saved!")),
    );
  }

  Future<void> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    nameController.text = prefs.getString('user_name') ?? '';
    ageController.text = prefs.getString('user_age') ?? '';
    addressController.text = prefs.getString('user_address') ?? '';
    dobController.text = prefs.getString('user_dob') ?? '';
    mobileController.text = prefs.getString('user_mobile') ?? '';
    emailController.text = prefs.getString('user_email') ?? '';
  }

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    addressController.dispose();
    dobController.dispose();
    mobileController.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: "Name")),
            TextField(controller: ageController, decoration: const InputDecoration(labelText: "Age"), keyboardType: TextInputType.number),
            TextField(controller: addressController, decoration: const InputDecoration(labelText: "Address")),
            TextField(controller: dobController, decoration: const InputDecoration(labelText: "Date of Birth")),
            TextField(controller: mobileController, decoration: const InputDecoration(labelText: "Mobile Number"), keyboardType: TextInputType.phone),
            TextField(controller: emailController, decoration: const InputDecoration(labelText: "Email"), keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: saveProfile, child: const Text("Save")),
          ],
        ),
      ),
    );
  }
}

