import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

class ContactService {
  /// Get all contacts with at least one phone number
  static Future<List<Contact>> getContacts() async {
    if (!await FlutterContacts.requestPermission()) {
      return [];
    }

    return await FlutterContacts.getContacts(withProperties: true);
  }

  /// Save selected contacts to Firebase
  static Future<void> saveSelectedContacts(List<Contact> contacts) async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final contactData = contacts.map((c) {
      return {
        'name': c.displayName,
        'phone': c.phones.isNotEmpty ? c.phones.first.number : '',
      };
    }).toList();

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .set({'priority_contacts': contactData}, SetOptions(merge: true));
  }

  /// Load saved priority contacts from Firebase
  static Future<List<Map<String, dynamic>>> loadSavedContacts() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    final data = doc.data();
    if (data == null || !data.containsKey('priority_contacts')) return [];

    return List<Map<String, dynamic>>.from(data['priority_contacts']);
  }
}