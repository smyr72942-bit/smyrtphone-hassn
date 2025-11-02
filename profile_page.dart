import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'edit_profile_page.dart'; // ← استيراد صفحة التعديل

class ProfilePage extends StatelessWidget {

  final User user = FirebaseAuth.instance.currentUser!;

  Future<DocumentSnapshot> getUserData() async {

    return await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

  }

  @override

  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(title: Text('الملف الشخصي')),

      body: FutureBuilder<DocumentSnapshot>(

        future: getUserData(),

        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {

            return Center(child: CircularProgressIndicator());

          }

          if (!snapshot.hasData || !snapshot.data!.exists) {

            return Center(child: Text('لم يتم العثور على بيانات المستخدم'));

          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          return Padding(

padding: const EdgeInsets.all(16),

            child: Column(

              children: [

                CircleAvatar(

                  radius: 50,

                  backgroundImage: NetworkImage(data['photoUrl'] ?? ''),

                ),

                SizedBox(height: 16),

                Text(data['name'] ?? 'بدون اسم', style: TextStyle(fontSize: 20)),

                SizedBox(height: 8),

                Text(data['email'] ?? '', style: TextStyle(color: Colors.grey[700])),

                SizedBox(height: 16),

                ElevatedButton.icon(

                  icon: Icon(Icons.edit),

                  label: Text('تعديل الملف الشخصي'),

                  onPressed: () {

                    Navigator.push(

                      context,

                      MaterialPageRoute(builder: (context) => EditProfilePage()),

                    );

                  },

                ),

              ],

            ),

          );

        },

      ),

    );

  }

}