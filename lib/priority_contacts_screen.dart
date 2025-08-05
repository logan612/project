import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:rapidrescue/services/contact_service.dart';

class PriorityContactsScreen extends StatefulWidget {
  const PriorityContactsScreen({Key? key}) : super(key: key);
  @override
  _PriorityContactsScreenState createState() => _PriorityContactsScreenState();
}

class _PriorityContactsScreenState extends State<PriorityContactsScreen> {
  List<Contact> allContacts = [];
  List<Contact> selectedContacts = [];
  List<Map<String, dynamic>> savedContacts = [];
  bool isLoading = true;
  bool showSavedContacts = false;

  @override
  void initState() {
    super.initState();
    loadContacts();
  }

  Future<void> loadContacts() async {
    bool permissionGranted = await FlutterContacts.requestPermission();

    if (!permissionGranted) {
      permissionGranted = await FlutterContacts.requestPermission();
    }

    if (!permissionGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Permission to access contacts denied')),
      );
      setState(() => isLoading = false);
      return;
    }

    final contacts = await ContactService.getContacts();
    setState(() {
      allContacts = contacts.where((c) => c.phones.isNotEmpty).toList();
      isLoading = false;
    });
  }

  void toggleSelection(Contact contact) {
    setState(() {
      if (selectedContacts.contains(contact)) {
        selectedContacts.remove(contact);
      } else {
        selectedContacts.add(contact);
      }
    });
  }

  Future<void> saveContacts() async {
    await ContactService.saveSelectedContacts(selectedContacts);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Priority contacts saved successfully!')),
    );
  }

  Future<void> loadSavedContacts() async {
    final contacts = await ContactService.loadSavedContacts();
    setState(() {
      savedContacts = contacts;
      showSavedContacts = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Select Priority Contacts'),
          actions: [
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: loadContacts,
            ),
          ],
        ),
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : allContacts.isEmpty
            ? Center(child: Text('No contacts found or access denied.'))
            : Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: allContacts.length,
                itemBuilder: (context, index) {
                  final contact = allContacts[index];
                  final isSelected = selectedContacts.contains(contact);
                  return ListTile(
                    title: Text(contact.displayName),
                    subtitle: Text(
                        contact.phones.isNotEmpty ? contact.phones.first.number : 'No number'),
                    trailing: Checkbox(
                      value: isSelected,
                      onChanged: (_) => toggleSelection(contact),
                    ),
                  );
                },
              ),
            ),
            if (showSavedContacts && savedContacts.isNotEmpty)
              Container(
                height: 150,
                padding: EdgeInsets.all(8),
                color: Colors.grey.shade100,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Saved Priority Contacts",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    Expanded(
                      child: ListView(
                        children: savedContacts.map((c) {
                          return ListTile(
                            title: Text(c['name'] ?? ''),
                            subtitle: Text(c['phone'] ?? ''),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        floatingActionButton: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FloatingActionButton.extended(
                onPressed: saveContacts,
                label: Text('Save'),
                icon: Icon(Icons.save),
              ),
              SizedBox(height: 10),
              FloatingActionButton.extended(
                onPressed: loadSavedContacts,
                label: Text('Show Saved'),
                icon: Icon(Icons.visibility),
              ),
            ],
            ),
       );
    }
}