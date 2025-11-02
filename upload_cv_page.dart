import 'package:flutter/material.dart';

import 'package:file_picker/file_picker.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:firebase_storage/firebase_storage.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class UploadCVPage extends StatefulWidget {

  @override

  _UploadCVPageState createState() => _UploadCVPageState();

}

class _UploadCVPageState extends State<UploadCVPage> {

  final User user = FirebaseAuth.instance.currentUser!;

  String? _cvUrl;

  bool _uploading = false;

  Future<void> pickAndUploadCV() async {

    setState(() => _uploading = true);

    final result = await FilePicker.platform.pickFiles(

      type: FileType.custom,

      allowedExtensions: ['pdf'],

    );

    if (result == null || result.files.isEmpty) {

      setState(() => _uploading = false);

      return;

    }

    final file = result.files.first;

    final fileBytes = file.bytes;

    final fileName = 'cv_${user.uid}.pdf';

    try {

      final ref = FirebaseStorage.instance.ref().child('cvs/$fileName');

      await ref.putData(fileBytes!);

      final downloadUrl = await ref.getDownloadURL();

await FirebaseFirestore.instance.collection('users').doc(user.uid).update({

        'cvUrl': downloadUrl,

      });

      setState(() {

        _cvUrl = downloadUrl;

        _uploading = false;

      });

    } catch (e) {

      setState(() => _uploading = false);

      ScaffoldMessenger.of(context).showSnackBar(

        SnackBar(content: Text('❌ فشل رفع الملف: $e')),

      );

    }

  }

  @override

  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(title: Text('رفع السيرة الذاتية')),

      body: Padding(

        padding: const EdgeInsets.all(16),

        child: Column(

          children: [

            ElevatedButton.icon(

              icon: Icon(Icons.upload_file),

              label: Text('اختيار ورفع ملف PDF'),

              onPressed: pickAndUploadCV,

            ),

            SizedBox(height: 20),
              
              _uploading

                ? CircularProgressIndicator()

                : _cvUrl != null

                    ? Text('✅ تم رفع السيرة الذاتية بنجاح', style: TextStyle(color: Colors.green))

                    : Text('لم يتم رفع أي ملف بعد'),

          ],

        ),

      ),

    );

  }

}