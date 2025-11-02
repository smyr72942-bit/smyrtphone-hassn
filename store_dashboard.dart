import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class StoreDashboard extends StatefulWidget {

  final String storeName;

  const StoreDashboard({super.key, required this.storeName});

  @override

  State<StoreDashboard> createState() => _StoreDashboardState();

}

class _StoreDashboardState extends State<StoreDashboard> {

  final TextEditingController titleController = TextEditingController();

  final TextEditingController cityController = TextEditingController();

  final TextEditingController salaryController = TextEditingController();

  final TextEditingController contactController = TextEditingController();

  Future<void> addStoreJob() async {

    await FirebaseFirestore.instance.collection('store_jobs').add({

      'title': titleController.text,

      'store': widget.storeName,

      'city': cityController.text,

      'salary': salaryController.text,

      'contact': contactController.text,

      'createdAt': Timestamp.now(),

    });

    ScaffoldMessenger.of(context).showSnackBar(

      const SnackBar(content: Text('✅ تم نشر وظيفة المتجر بنجاح')),

    );

    titleController.clear();

    cityController.clear();

    salaryController.clear();

    contactController.clear();

  }

  @override

Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title: Text('لوحة متجر ${widget.storeName}'),

        backgroundColor: Colors.orange,

      ),

      body: Padding(

        padding: const EdgeInsets.all(16),

        child: Column(

          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            const Text(

              'أضف فرصة عمل من المتجر',

              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),

            ),

            const SizedBox(height: 15),

            TextField(

              controller: titleController,

              decoration: const InputDecoration(

                labelText: 'اسم الوظيفة (مثلاً: عامل، كاشير...)',

border: OutlineInputBorder(),

              ),

            ),

            const SizedBox(height: 10),

            TextField(

              controller: cityController,

              decoration: const InputDecoration(

                labelText: 'المدينة',

                border: OutlineInputBorder(),

              ),

            ),

            const SizedBox(height: 10),

            TextField(

              controller: salaryController,

              decoration: const InputDecoration(

                labelText: 'الراتب الشهري (د.ع)',

                border: OutlineInputBorder(),

              ),

            ),

            const SizedBox(height: 10),

            TextField(

              controller: contactController,

              decoration: const InputDecoration(

                labelText: 'رقم التواصل أو واتساب',

                border: OutlineInputBorder(),

              ),

              keyboardType: TextInputType.phone,
                
                   ),

            const SizedBox(height: 15),

            ElevatedButton.icon(

              icon: const Icon(Icons.store),

              label: const Text('نشر فرصة المتجر'),

              style: ElevatedButton.styleFrom(

                backgroundColor: Colors.orange,

                minimumSize: const Size(double.infinity, 45),

              ),

              onPressed: addStoreJob,

            ),

            const Divider(height: 40),

            const Text(

              'قائمة فرص المتاجر:',

              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),

            ),
              
              const SizedBox(height: 10),

            Expanded(

              child: StreamBuilder<QuerySnapshot>(

                stream: FirebaseFirestore.instance

                    .collection('store_jobs')

                    .orderBy('createdAt', descending: true)

                    .snapshots(),

                builder: (context, snapshot) {

                  if (!snapshot.hasData) {

                    return const Center(child: CircularProgressIndicator());

                  }

                  final jobs = snapshot.data!.docs;

                  if (jobs.isEmpty) {

                    return const Center(child: Text('لا توجد فرص حالياً 💤'));

                  }

                  return ListView.builder(

                    itemCount: jobs.length,

                    itemBuilder: (context, index) {

                      final job = jobs[index];

                      return Card(
                          
                          child: ListTile(

                          title: Text(job['title']),

                          subtitle: Text(

                              "${job['city']} - ${job['salary']} د.ع\nتواصل: ${job['contact']}"),

                        ),

                      );

                    },

                  );

                },

              ),

            ),

          ],

        ),

      ),

    );

  }

}