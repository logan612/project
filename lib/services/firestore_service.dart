import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> saveUserProfile({
    required String name,
    required String dob,
    required String address,
    required String mobile,
    required String email,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    await _firestore.collection('users').doc(uid).set({
      'name': name,
      'dob': dob,
      'address': address,
      'mobile': mobile,
      'email': email,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> savePriorityContact(String name, String number) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    await _firestore
        .collection('users')
        .doc(uid)
        .collection('priority_contacts')
        .add({
      'name': name,
      'number': number,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
