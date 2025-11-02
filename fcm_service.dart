import 'package:firebase_auth/firebase_auth.dart';

import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> saveFcmToken() async {

  final uid = FirebaseAuth.instance.currentUser?.uid;

  if (uid == null) return;

  final token = await FirebaseMessaging.instance.getToken();

  if (token != null) {

    await FirebaseFirestore.instance.collection('users').doc(uid).set({

      'fcmToken': token,

    }, SetOptions(merge: true));

  }

}