import 'package:http/http.dart' as http;

import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> sendPushNotification(String token, String title, String body) async {

  const serverKey = 'AAAAxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'; // استبدله بمفتاح FCM الحقيقي

  await http.post(

    Uri.parse('https://fcm.googleapis.com/fcm/send'),

    headers: {

      'Content-Type': 'application/json',

      'Authorization': 'key=$serverKey',

    },

    body: '''

    {

      "to": "$token",

      "notification": {

        "title": "$title",

        "body": "$body"

      }

    }

    ''',

  );

}

Future<void> notifyUsersAboutNewJob(String city, String jobTitle) async {

  final users = await FirebaseFirestore.instance

      .collection('users')

      .where('city', isEqualTo: city)

      .get();

  for (var user in users.docs) {

    final token = user['fcmToken'];

    if (token != null) {

      await sendPushNotification(

        token,

        "📢 وظيفة جديدة في $city",

        jobTitle,

      );

    }

  }

}