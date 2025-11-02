import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:url_launcher/url_launcher.dart';

class ApplicantsPage extends StatefulWidget {

  final String jobId;

  final String jobTitle;

  const ApplicantsPage({

    super.key,

    required this.jobId,

    required this.jobTitle,

  });

  @override

  State<ApplicantsPage> createState() => _ApplicantsPageState();

}

class _ApplicantsPageState extends State<ApplicantsPage> {

  String searchQuery = '';

  @override

  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(title: Text('المتقدمين لـ ${widget.jobTitle}')),

      body: Column(

        children: [

          Padding(

            padding: const EdgeInsets.all(12),

            child: TextField(

              decoration: InputDecoration(

                labelText: 'ابحث عن متقدم',

                prefixIcon: const Icon(Icons.search),

                border: OutlineInputBorder(

                  borderRadius: BorderRadius.circular(12),

                ),

              ),

              onChanged: (value) {

                setState(() => searchQuery = value.toLowerCase());

              },

            ),

          ),

          Expanded(

            child: StreamBuilder<QuerySnapshot>(

              stream: FirebaseFirestore.instance

                  .collection('applications')

                  .where('jobId', isEqualTo: widget.jobId)

                  .orderBy('createdAt', descending: true)

                  .snapshots(),

              builder: (context, snapshot) {

                if (snapshot.connectionState == ConnectionState.waiting) {

                  return const Center(child: CircularProgressIndicator());

                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {

                  return const Center(child: Text('لا يوجد متقدمين حالياً'));

                }

                final applicants = snapshot.data!.docs.where((doc) {

                  final data = doc.data() as Map<String, dynamic>;

                  final name = (data['name'] ?? '').toString().toLowerCase();

                  return name.contains(searchQuery);

                }).toList();

                if (applicants.isEmpty) {

                  return const Center(child: Text('لا يوجد نتائج مطابقة للبحث'));

                }

                return ListView.builder(

                  itemCount: applicants.length,

                  itemBuilder: (context, index) {

                    final appData = applicants[index].data() as Map<String, dynamic>;

                    return Card(

                      elevation: 3,

                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),

                      shape: RoundedRectangleBorder(

                        borderRadius: BorderRadius.circular(12),

                      ),

                      child: ListTile(

                        leading: const CircleAvatar(child: Icon(Icons.person)),

                        title: Text(

                          appData['name'] ?? 'بدون اسم',

                          style: const TextStyle(fontWeight: FontWeight.bold),

                        ),

                        subtitle: Column(

                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [

                            Text('📧 البريد: ${appData['email'] ?? 'غير متوفر'}'),

                            Text('💼 الخبرة: ${appData['experience'] ?? 'بدون خبرة'}'),

                            Text('📅 تاريخ التقديم: ${appData['createdAt'] != null ? (appData['createdAt'] as Timestamp).toDate().toString().split(" ")[0] : 'غير محدد'}'),

                            if (appData['cv'] != null)

                              InkWell(

                                onTap: () async {

                                  final cvUrl = appData['cv'];

                                  if (await canLaunchUrl(Uri.parse(cvUrl))) {

                                    await launchUrl(Uri.parse(cvUrl), mode: LaunchMode.externalApplication);

                                  }

                                },

                                child: const Text(

                                  '📄 عرض السيرة الذاتية',

                                  style: TextStyle(

                                    color: Colors.blue,

                                    decoration: TextDecoration.underline,

                                  ),

                                ),

                              ),

                            const SizedBox(height: 8),

                          ],

                        ),

                        trailing: Row(

                          mainAxisSize: MainAxisSize.min,

                          children: [

                            IconButton(

                              icon: const Icon(Icons.check_circle, color: Colors.green),

                              tooltip: 'قبول المتقدم',

                              onPressed: () async {

                                await FirebaseFirestore.instance

                                    .collection('applications')

                                    .doc(applicants[index].id)

                                    .update({'status': 'accepted'});

                              },

                            ),

                            IconButton(

                              icon: const Icon(Icons.cancel, color: Colors.red),

                              tooltip: 'رفض المتقدم',

                              onPressed: () async {

                                await FirebaseFirestore.instance

                                    .collection('applications')

                                    .doc(applicants[index].id)

                                    .update({'status': 'rejected'});

                              },

                            ),

                          ],

                        ),

                      ),

                    );

                  },

                );

              },

            ),

          ),

        ],

      ),

    );

  }

}