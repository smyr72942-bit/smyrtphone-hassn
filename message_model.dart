// نموذج الرسالة

import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {

  final String id;

  final String chatId;

  final String fromUid;

  final String fromName;

  final String text;

  final String? attachmentUrl;

  final String? attachmentName;

  final Timestamp sentAt;

  final bool read;

  ChatMessage({

    required this.id,

    required this.chatId,

    required this.fromUid,

    required this.fromName,

    required this.text,

    this.attachmentUrl,

    this.attachmentName,

    required this.sentAt,

    required this.read,

  });

  factory ChatMessage.fromDoc(DocumentSnapshot doc) {

    final d = doc.data() as Map<String, dynamic>;

    return ChatMessage(

      id: doc.id,

      chatId: d['chatId'] ?? '',

      fromUid: d['fromUid'] ?? '',

      fromName: d['fromName'] ?? '',

      text: d['text'] ?? '',

      attachmentUrl: d['attachmentUrl'],

      attachmentName: d['attachmentName'],

      sentAt: d['sentAt'] ?? Timestamp.now(),
        
        read: d['read'] ?? false,

    );

  }

  Map<String, dynamic> toMap() => {

        'chatId': chatId,

        'fromUid': fromUid,

        'fromName': fromName,

        'text': text,

        'attachmentUrl': attachmentUrl,

        'attachmentName': attachmentName,

        'sentAt': FieldValue.serverTimestamp(),

        'read': false,

      };

}