import 'dart:io';

import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_storage/firebase_storage.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:file_picker/file_picker.dart';

import 'package:intl/intl.dart';

import 'package:url_launcher/url_launcher.dart';

class ChatScreen extends StatefulWidget {

  final String chatId;

  final String otherName;

  final String otherUid;

  const ChatScreen({

    super.key,

    required this.chatId,

    required this.otherName,

    required this.otherUid,

  });

  @override

  State<ChatScreen> createState() => _ChatScreenState();

}

class _ChatScreenState extends State<ChatScreen> {

  final _ctrl = TextEditingController();

  final _scroll = ScrollController();

  bool sending = false;

  Stream<QuerySnapshot> messagesStream() {

    return FirebaseFirestore.instance

        .collection('chats')

        .doc(widget.chatId)

        .collection('messages')

        .orderBy('sentAt', descending: true)

        .snapshots();

  }

  Future<void> sendText(String text, {String? attachUrl, String? attachName}) async {

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    if ((text.trim().isEmpty) && attachUrl == null) return;

    final docRef = FirebaseFirestore.instance

        .collection('chats')

        .doc(widget.chatId)

        .collection('messages')

        .doc();

    final map = {

      'chatId': widget.chatId,

      'fromUid': user.uid,

      'fromName': user.displayName ?? user.email ?? 'User',

      'text': text,

      'attachmentUrl': attachUrl,

      'attachmentName': attachName,

      'sentAt': FieldValue.serverTimestamp(),

      'read': false,

    };

    await docRef.set(map);

    await FirebaseFirestore.instance.collection('chats').doc(widget.chatId).set({

      'lastMessage': text.isEmpty ? (attachName ?? 'ملف') : text,

      'lastFrom': user.uid,

      'lastAt': FieldValue.serverTimestamp(),

      'participants': [user.uid, widget.otherUid],

    }, SetOptions(merge: true));

    _ctrl.clear();

    _scroll.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);

  }

  Future<void> pickAndSendFile() async {

    final res = await FilePicker.platform.pickFiles(

      type: FileType.custom,

      allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'png'],

    );

    if (res == null || res.files.single.path == null) return;

    setState(() => sending = true);

    final file = File(res.files.single.path!);

    final name = res.files.single.name;

    final path = 'chat_attachments/${widget.chatId}/${DateTime.now().millisecondsSinceEpoch}_$name';

    final ref = FirebaseStorage.instance.ref().child(path);

    final task = await ref.putFile(file);

    final url = await task.ref.getDownloadURL();

    await sendText('', attachUrl: url, attachName: name);

    setState(() => sending = false);

  }

  Widget _buildMessageItem(DocumentSnapshot doc) {

    final d = doc.data() as Map<String, dynamic>;

    final uid = FirebaseAuth.instance.currentUser?.uid;

    final isMe = d['fromUid'] == uid;

    final sentAt = d['sentAt'] is Timestamp ? (d['sentAt'] as Timestamp).toDate() : DateTime.now();

    return Align(

      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,

      child: Container(

        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),

        padding: const EdgeInsets.all(10),

        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),

        decoration: BoxDecoration(

          color: isMe ? Colors.blue.shade50 : Colors.grey.shade100,

          borderRadius: BorderRadius.circular(10),

        ),

        child: Column(

          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,

          children: [

            if (d['attachmentUrl'] != null)

              GestureDetector(

                onTap: () async {

                  final url = d['attachmentUrl'] as String;

                  if (await canLaunchUrl(Uri.parse(url))) {

                    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);

                  }

                },

                child: Column(

                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [

                    Icon(Icons.attach_file, color: Colors.grey[700]),

                    const SizedBox(height: 4),

                    Text(d['attachmentName'] ?? 'ملف', style: const TextStyle(fontWeight: FontWeight.bold)),

                    const SizedBox(height: 8),

                  ],

                ),

              ),

            if ((d['text'] ?? '').toString().isNotEmpty) Text(d['text']),

            const SizedBox(height: 6),

            Row(

              mainAxisSize: MainAxisSize.min,

              children: [

                Text(DateFormat('hh:mm a').format(sentAt), style: const TextStyle(fontSize: 11, color: Colors.grey)),

                const SizedBox(width: 6),

                if (isMe)

                  Icon(Icons.check, size: 14, color: (d['read'] ?? false) ? Colors.blue : Colors.grey),

              ],

            ),

          ],

        ),

      ),

    );

  }

  @override

  Widget build(BuildContext context) {

    final title = widget.otherName;

    return Directionality(

      textDirection: Localizations.localeOf(context).languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr,

      child: Scaffold(

        appBar: AppBar(

          title: Text(title),

          actions: [

            IconButton(icon: const Icon(Icons.attach_file), onPressed: pickAndSendFile),

          ],

        ),

        body: Column(

          children: [

            Expanded(

              child: StreamBuilder<QuerySnapshot>(

                stream: messagesStream(),

                builder: (context, snap) {

                  if (snap.connectionState == ConnectionState.waiting) {

                    return const Center(child: CircularProgressIndicator());

                  }

                  if (!snap.hasData || snap.data!.docs.isEmpty) {

                    return const Center(child: Text('لا رسائل بعد'));

                  }

                  final docs = snap.data!.docs;

                  return ListView.builder(

                    reverse: true,

                    controller: _scroll,

                    itemCount: docs.length,

                    itemBuilder: (ctx, i) => _buildMessageItem(docs[i]),

                  );

                },

              ),

            ),

            if (sending) const LinearProgressIndicator(),

            SafeArea(

              child: Container(

                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),

                color: Colors.white,

                child: Row(

                  children: [

                    IconButton(onPressed: pickAndSendFile, icon: const Icon(Icons.upload_file)),

                    Expanded(

                      child: TextField(

                        controller: _ctrl,

                        decoration: const InputDecoration(hintText: 'اكتب رسالة...', border: InputBorder.none),

                      ),

                    ),

                    IconButton(onPressed: () => sendText(_ctrl.text), icon: const Icon(Icons.send, color: Colors.blue)),

                  ],

                ),

              ),

            ),

          ],

        ),

      ),

    );

  }

}