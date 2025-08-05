import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';
import 'home_screen.dart';


class UnifiedLoginScreen extends StatefulWidget {
  const UnifiedLoginScreen({super.key});

  @override
  State<UnifiedLoginScreen> createState() => _UnifiedLoginScreenState();
}

class _UnifiedLoginScreenState extends State<UnifiedLoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final logger = Logger();

  bool isPhoneLogin = false;
  bool otpSent = false;
  bool isLoading = false;
  String? verificationId;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final phoneController = TextEditingController();
  final otpController = TextEditingController();

  void toggleLoginMethod() {
    setState(() {
      isPhoneLogin = !isPhoneLogin;
      otpSent = false;
    });
    logger.i("Switched to ${isPhoneLogin ? 'Phone' : 'Email'} login");
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
    logger.e(message);
  }

  void navigateToHome() {
    final user = FirebaseAuth.instance.currentUser;
    logger.i("Navigating to Home. Firebase user: ${user?.uid}");

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  Future<void> signInWithEmail() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      showError("Please enter email and password.");
      return;
    }

    try {
      setState(() => isLoading = true);
      logger.d("Attempting email login for $email");

      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        logger.i("Email login success: ${userCredential.user!.uid}");
        navigateToHome();
      } else {
        showError("Login failed. Please try again.");
      }
    } on FirebaseAuthException catch (e) {
      showError("Login failed: ${e.message}");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> sendOTP() async {
    String phone = phoneController.text.trim();
    if (phone.isEmpty || phone.length < 10) {
      showError("Please enter a valid phone number.");
      return;
    }

    String formattedPhone = phone.startsWith("+") ? phone : "+91$phone";

    logger.d("Sending OTP to $formattedPhone");
    setState(() => isLoading = true);

    await _auth.verifyPhoneNumber(
      phoneNumber: formattedPhone,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        logger.i("Auto-verification complete");
        try {
          await _auth.signInWithCredential(credential);
          navigateToHome();
        } catch (e) {
          showError("Auto-verification failed: $e");
        }
      },
      verificationFailed: (FirebaseAuthException e) {
        showError("Verification failed: ${e.message}");
        if (mounted) setState(() => isLoading = false);
      },
      codeSent: (String verId, int? resendToken) {
        if (mounted) {
          setState(() {
            verificationId = verId;
            otpSent = true;
            isLoading = false;
          });
        }
        logger.i("OTP sent. Verification ID: $verId");
      },
      codeAutoRetrievalTimeout: (String verId) {
        verificationId = verId;
        logger.w("OTP auto-retrieval timeout");
      },
    );
  }

  Future<void> verifyOTP() async {
    String otp = otpController.text.trim();
    if (otp.isEmpty || otp.length < 6) {
      showError("Enter a valid 6-digit OTP");
      return;
    }

    try {
      setState(() => isLoading = true);
      logger.d("Verifying OTP with verificationId: $verificationId");

      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId!,
        smsCode: otp,
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user != null) {
        logger.i("Phone login success: ${userCredential.user!.uid}");
        navigateToHome();
      } else {
        showError("OTP verification failed.");
      }
    } on FirebaseAuthException catch (e) {
      showError("Invalid OTP: ${e.message}");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SwitchListTile(
              title: Text(isPhoneLogin ? "Phone Login" : "Email Login"),
              value: isPhoneLogin,
              onChanged: (_) => toggleLoginMethod(),
            ),
            if (isPhoneLogin) ...[
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: "Phone (+91...)"),
                keyboardType: TextInputType.phone,
              ),
              if (otpSent)
                TextField(
                  controller: otpController,
                  decoration: const InputDecoration(labelText: "OTP"),
                  keyboardType: TextInputType.number,
                ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: otpSent ? verifyOTP : sendOTP,
                child: Text(otpSent ? "Verify OTP" : "Send OTP"),
              ),
            ] else ...[
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: "Email"),
              ),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: "Password"),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: signInWithEmail,
                child: const Text("Login"),
              ),
            ]
          ],
        ),
      ),
    );
  }
}