// lib/pages/company_profile_page.dart

import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class CompanyProfilePage extends StatelessWidget {

  final String companyId;

  const CompanyProfilePage({super.key, required this.companyId});

  @override

  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(title: const Text('ملف الشركة'), backgroundColor: Colors.blue),

      body: FutureBuilder<DocumentSnapshot>(

        future: FirebaseFirestore.instance.collection('companies').doc(companyId).get(),

        builder: (context, snapshot) {

          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final company = snapshot.data!.data() as Map<String, dynamic>?;

          if (company == null) return const Center(child: Text('لم يتم العثور على بيانات الشركة'));

          return Padding(

            padding: const EdgeInsets.all(16),

            child: Column(

              crossAxisAlignment: CrossAxisAlignment.start,

              children: [

                Text(company['name'] ?? 'شركة غير معروفة', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),

                const SizedBox(height: 8),

                Text("📍 ${company['city'] ?? 'مدينة غير محددة'} • ${company['country'] ?? 'دولة غير محددة'}", style: const TextStyle(fontSize: 16)),

                const SizedBox(height: 12),

                if (company['description'] != null)

                  Text(company['description'], style: const TextStyle(fontSize: 15)),

                const SizedBox(height: 20),

                const Text("الوظائف المنشورة:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

                const SizedBox(height: 10),

                Expanded(

                  child: StreamBuilder<QuerySnapshot>(

                    stream: FirebaseFirestore.instance

                        .collection('jobs')

                        .where('companyId', isEqualTo: companyId)

                        .snapshots(),

                    builder: (context, jobSnapshot) {

                      if (!jobSnapshot.hasData) return const Center(child: CircularProgressIndicator());

                      final jobs = jobSnapshot.data!.docs;

                      if (jobs.isEmpty) return const Text('لا توجد وظائف حالياً');

                      return ListView.builder(

                        itemCount: jobs.length,

                        itemBuilder: (context, index) {

                          final job = jobs[index].data() as Map<String, dynamic>;

                          return ListTile(

                            title: Text(job['title'] ?? 'بدون عنوان'),

                            subtitle: Text(job['city'] ?? ''),

                            trailing: Text(job['salary'] ?? ''),

                            onTap: () {

                              // تقدر تربطها بـ JobDetailsPage

                            },

                          );

                        },

                      );

                    },

                  ),

                ),

              ],

            ),

          );

        },

      ),

    );

  }

}