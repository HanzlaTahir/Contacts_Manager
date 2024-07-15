import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // for restricting TextField input
import 'package:google_fonts/google_fonts.dart'; // for custom fonts
import 'package:image_picker/image_picker.dart'; // for picking images
import 'dart:io';
import 'database_helper.dart';
import 'contact.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: GoogleFonts.latoTextTheme(),
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final DatabaseHelper dbHelper = DatabaseHelper();
  List<Contact> contacts = [];
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final updatePhoneController = TextEditingController();
  File? _image;

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  void _loadContacts() async {
    final data = await dbHelper.getContacts();
    setState(() {
      contacts = data.map((item) => Contact.fromMap(item)).toList();
    });
  }

  void _addContact(Contact contact) async {
    await dbHelper.insertContact(contact.toMap());
    _loadContacts();
  }

  void _deleteContact(int id) async {
    await dbHelper.deleteContact(id);
    _loadContacts();
  }

  void _updateContactPhone(int id, String newPhone) async {
    await dbHelper.updateContactPhone(id, newPhone);
    _loadContacts();
  }

  void _updateContactImage(int id, String newImage) async {
    await dbHelper.updateContactImage(id, newImage);
    _loadContacts();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  void _showUpdateDialog(Contact contact) {
    updatePhoneController.text = contact.phone;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update Phone Number'),
        content: TextField(
          controller: updatePhoneController,
          decoration: InputDecoration(
            labelText: 'New Phone Number',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.phone,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.digitsOnly,
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              final newPhone = updatePhoneController.text;
              if (newPhone.isNotEmpty) {
                _updateContactPhone(contact.id!, newPhone);
                updatePhoneController.clear();
                Navigator.of(context).pop();
              }
            },
            child: Text('Update'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contact Manager'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: contacts.isEmpty
                  ? Center(child: Text('No Contacts Found'))
                  : ListView.builder(
                itemCount: contacts.length,
                itemBuilder: (context, index) {
                  final contact = contacts[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      leading: GestureDetector(
                        onTap: () async {
                          await _pickImage();
                          if (_image != null) {
                            _updateContactImage(contact.id!, _image!.path);
                          }
                        },
                        child: CircleAvatar(
                          backgroundImage: contact.image != null
                              ? FileImage(File(contact.image!))
                              : null,
                          child: contact.image == null
                              ? Text(
                            contact.name[0].toUpperCase(),
                            style: TextStyle(color: Colors.white),
                          )
                              : null,
                          backgroundColor: Colors.blue,
                        ),
                      ),
                      title: Text(contact.name),
                      subtitle: Text(contact.phone),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () => _showUpdateDialog(contact),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () => _deleteContact(contact.id!),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Column(
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Name',
                    ),
                  ),
                  SizedBox(height: 8.0),
                  TextField(
                    controller: phoneController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Phone',
                    ),
                    keyboardType: TextInputType.phone,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                  ),
                  SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () {
                      final name = nameController.text;
                      final phone = phoneController.text;
                      if (name.isNotEmpty && phone.isNotEmpty) {
                        _addContact(Contact(name: name, phone: phone, image: _image?.path));
                        nameController.clear();
                        phoneController.clear();
                        setState(() {
                          _image = null;
                        });
                      }
                    },
                    child: Text('Add Contact'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
                      textStyle: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
