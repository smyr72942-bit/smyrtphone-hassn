import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'applicants_page.dart';

class CompanyDashboard extends StatefulWidget {

  final String companyId;

  final String companyName;

  const CompanyDashboard({

    super.key,

    required this.companyId,

    required this.companyName,

  });

  @override

  State<CompanyDashboard> createState() => _CompanyDashboardState();

}

class _CompanyDashboardState extends State<CompanyDashboard> {

  final TextEditingController titleController = TextEditingController();

  final TextEditingController cityController = TextEditingController();

  final TextEditingController salaryController = TextEditingController();

  final TextEditingController categoryController = TextEditingController();

  final TextEditingController typeController = TextEditingController();

  Future<void> addJob() async {

    if (titleController.text.isEmpty || cityController.text.isEmpty) return;

    await FirebaseFirestore.instance.collection('jobs').add({

      'title': titleController.text,

      'city': cityController.text,

      'salary': salaryController.text,

      'category': categoryController.text,

      'type': typeController.text,

      'company': widget.companyName,

      'companyId': widget.companyId,

      'createdAt': Timestamp.now(),

    });

    titleController.clear();

    cityController.clear();

    salaryController.clear();

    categoryController.clear();

    typeController.clear();

    ScaffoldMessenger.of(context).showSnackBar(

      const SnackBar(content: Text('✅ تمت إضافة الوظيفة بنجاح')),

    );

  }

  @override

  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(title: Text("لوحة ${widget.companyName}")),

      body: Padding(

        padding: const EdgeInsets.all(12.0),

        child: Column(

          children: [

            const Text("إضافة وظيفة جديدة", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),

            const SizedBox(height: 12),

            _buildField("عنوان الوظيفة", titleController),

            _buildField("المدينة", cityController),

            _buildField("الراتب", salaryController),

            _buildField("التصنيف", categoryController),

            _buildField("نوع الدوام", typeController),

            const SizedBox(height: 15),

            ElevatedButton.icon(

              onPressed: addJob,

              icon: const Icon(Icons.add),

              label: const Text("إضافة الوظيفة"),

              style: ElevatedButton.styleFrom(

                backgroundColor: Colors.blue,

                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),

              ),

            ),

            const SizedBox(height: 20),

            const Divider(),

            const Text("الوظائف التي أضفتها:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),

            const SizedBox(height: 10),

            Expanded(

              child: StreamBuilder<QuerySnapshot>(

                stream: FirebaseFirestore.instance

                    .collection('jobs')

                    .where('companyId', isEqualTo: widget.companyId)

                    .orderBy('createdAt', descending: true)

                    .snapshots(),

                builder: (context, snapshot) {

                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                  final jobs = snapshot.data!.docs;

                  if (jobs.isEmpty) return const Center(child: Text("لا توجد وظائف بعد"));

                  return ListView.builder(

                    itemCount: jobs.length,

                    itemBuilder: (context, index) {

                      final job = jobs[index].data() as Map<String, dynamic>;

                      final jobId = jobs[index].id;

                      return Card(

                        margin: const EdgeInsets.symmetric(vertical: 6),

                        child: ListTile(

                          title: Text(job['title'] ?? 'بدون عنوان'),

                          subtitle: Text("${job['city']} • ${job['type']} • ${job['salary']} د.ع"),

                          trailing: IconButton(

                            icon: const Icon(Icons.delete, color: Colors.red),

                            onPressed: () => FirebaseFirestore.instance.collection('jobs').doc(jobId).delete(),

                          ),

                          onTap: () {

                            Navigator.push(

                              context,

                              MaterialPageRoute(

                                builder: (_) => ApplicantsPage(jobId: jobId, jobTitle: job['title'] ?? 'وظيفة'),

                              ),

                            );

                          },

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

  Widget _buildField(String label, TextEditingController controller) {

    return Padding(

      padding: const EdgeInsets.symmetric(vertical: 6),

      child: TextField(

        controller: controller,

        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),

      ),

    );

  }

}