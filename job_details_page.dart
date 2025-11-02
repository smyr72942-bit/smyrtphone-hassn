import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../providers/language_provider.dart';

import '../models/job_model.dart';

import 'company_profile_page.dart'; // ✅ تأكد من وجود هذه الصفحة

class JobDetailsPage extends StatelessWidget {

  final Job job;

  const JobDetailsPage({super.key, required this.job});

  @override

  Widget build(BuildContext context) {

    final isAr = Provider.of<LanguageProvider>(context).isArabic;

    String t(String ar, String en) => isAr ? ar : en;

    return Directionality(

      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,

      child: Scaffold(

        appBar: AppBar(

          title: Text(t('تفاصيل الوظيفة', 'Job Details')),

          backgroundColor: Colors.blue,

        ),

        body: Padding(

          padding: const EdgeInsets.all(16.0),

          child: ListView(

            children: [

              Card(

                elevation: 4,

                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),

                child: Padding(

                  padding: const EdgeInsets.all(16.0),

                  child: Column(

                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [

                      Text(job.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),

                      const SizedBox(height: 6),

                      Row(

                        children: [

                          Expanded(

                            child: Text("${job.city} • ${job.country}",

                                style: TextStyle(fontSize: 16, color: Colors.grey[700])),

                          ),

                          TextButton.icon(

                            icon: const Icon(Icons.business),

                            label: Text(job.company),

                            onPressed: () {

                              Navigator.push(context, MaterialPageRoute(

                                builder: (_) => CompanyProfilePage(companyId: job.companyId),

                              ));

                            },

                          ),

                        ],

                      ),

                      const Divider(height: 20, thickness: 1),

                      Text("${t('المجال', 'Category')}: ${job.category}"),

                      Text("${t('نوع الدوام', 'Job Type')}: ${job.jobType}"),

                      Text("${t('الراتب', 'Salary')}: ${job.salary} ${isAr ? 'د.ع' : 'IQD'}"),

                      if (job.description != null && job.description!.isNotEmpty) ...[

                        const SizedBox(height: 12),

                        Text(t('الوصف الوظيفي', 'Job Description'),

                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

                        const SizedBox(height: 6),

                        Text(job.description!, style: const TextStyle(fontSize: 15)),

                      ]

                    ],

                  ),

                ),

              ),

              const SizedBox(height: 24),

              ElevatedButton.icon(

                icon: const Icon(Icons.send),

                label: Text(t('تقديم على الوظيفة', 'Apply')),

                onPressed: () {

                  showDialog(

                    context: context,

                    builder: (_) => AlertDialog(

                      title: Text(t('تم التقديم', 'Application Sent')),

                      content: Text(t('تم التقديم على الوظيفة بنجاح ✅', 'You have successfully applied for this job ✅')),

                      actions: [

                        TextButton(

                          child: Text(t('حسناً', 'OK')),

                          onPressed: () => Navigator.of(context).pop(),

                        )

                      ],

                    ),

                  );

                },

                style: ElevatedButton.styleFrom(

                  minimumSize: const Size.fromHeight(50),

                  backgroundColor: Colors.blue,

                ),

              ),

            ],

          ),

        ),

      ),

    );

  }

}