import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class EditProfilePage extends StatefulWidget {

  @override

  _EditProfilePageState createState() => _EditProfilePageState();

}

class _EditProfilePageState extends State<EditProfilePage> {

  final User user = FirebaseAuth.instance.currentUser!;

  final TextEditingController _nameController = TextEditingController();

  final TextEditingController _photoController = TextEditingController();

  Future<void> loadUserData() async {

    final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

    final data = doc.data();

    if (data != null) {

      _nameController.text = data['name'] ?? '';

      _photoController.text = data['photoUrl'] ?? '';

    }

  }

  Future<void> saveChanges() async {

    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({

      'name': _nameController.text.trim(),

      'photoUrl': _photoController.text.trim(),

    });

    Navigator.pop(context); // يرجع للصفحة السابقة بعد الحفظ

  }

@override

  void initState() {

    super.initState();

    loadUserData();

  }

  @override

  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(title: Text('تعديل الملف الشخصي')),

      body: Padding(

        padding: const EdgeInsets.all(16),

        child: Column(

          children: [

            TextField(

              controller: _nameController,

              decoration: InputDecoration(labelText: 'الاسم'),

            ),

            SizedBox(height: 12),

            TextField(

              controller: _photoController,

              decoration: InputDecoration(labelText: 'رابط الصورة الشخصية'),

            ),

            SizedBox(height: 20),

            ElevatedButton.icon(

              icon: Icon(Icons.save),

              label: Text('حفظ التغييرات'),

onPressed: saveChanges,

            ),

          ],

        ),

      ),

    );

  }

}