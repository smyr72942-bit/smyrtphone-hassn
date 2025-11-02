import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:provider/provider.dart';

import '../providers/language_provider.dart';

import '../providers/job_provider.dart';

class AddJobPage extends StatefulWidget {

  final String companyName;

  final String companyId; // ✅ إضافة معرف الشركة

  const AddJobPage({super.key, required this.companyName, required this.companyId});

  @override

  State<AddJobPage> createState() => _AddJobPageState();

}

class _AddJobPageState extends State<AddJobPage> {

  final _formKey = GlobalKey<FormState>();

  final Map<String, String> jobData = {};

  @override

  Widget build(BuildContext context) {

    final isAr = Provider.of<LanguageProvider>(context).isArabic;

    final jobProvider = Provider.of<JobProvider>(context);

    String t(String ar, String en) => isAr ? ar : en;

    return Directionality(

      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,

      child: Scaffold(

        appBar: AppBar(

          title: Text(t('إضافة وظيفة جديدة', 'Add New Job')),

          backgroundColor: Colors.blue,

        ),

        body: Padding(

          padding: const EdgeInsets.all(16),

          child: Form(

            key: _formKey,

            child: ListView(

              children: [

                TextFormField(

                  decoration: InputDecoration(labelText: t('عنوان الوظيفة', 'Job Title')),

                  validator: (v) => v!.isEmpty ? t('مطلوب', 'Required') : null,

                  onSaved: (v) => jobData['title'] = v!,

                ),

                const SizedBox(height: 10),

                DropdownButtonFormField<String>(

                  decoration: InputDecoration(labelText: t('الدولة', 'Country')),

                  value: jobData['country'],

                  items: jobProvider.countries

                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))

                      .toList(),

                  onChanged: (v) => setState(() => jobData['country'] = v!),

                  validator: (v) => v == null ? t('مطلوب', 'Required') : null,

                ),

                const SizedBox(height: 10),

                DropdownButtonFormField<String>(

                  decoration: InputDecoration(labelText: t('المدينة', 'City')),

                  value: jobData['city'],

                  items: (jobData['country'] != null

                          ? jobProvider.citiesByCountry(jobData['country']!)

                          : [])

                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))

                      .toList(),

                  onChanged: (v) => setState(() => jobData['city'] = v!),

                  validator: (v) => v == null ? t('مطلوب', 'Required') : null,

                ),

                const SizedBox(height: 10),

                DropdownButtonFormField<String>(

                  decoration: InputDecoration(labelText: t('نوع الوظيفة', 'Job Type')),

                  items: jobProvider.jobTypes

                      .map((type) => DropdownMenuItem(value: type, child: Text(type)))

                      .toList(),

                  onChanged: (v) => setState(() => jobData['type'] = v!),

                  validator: (v) => v == null ? t('مطلوب', 'Required') : null,

                ),

                const SizedBox(height: 10),

                DropdownButtonFormField<String>(

                  decoration: InputDecoration(labelText: t('المجال', 'Category')),

                  items: jobProvider.categories

                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))

                      .toList(),

                  onChanged: (v) => setState(() => jobData['category'] = v!),

                ),

                const SizedBox(height: 10),

                TextFormField(

                  decoration: InputDecoration(labelText: t('الراتب', 'Salary')),

                  onSaved: (v) => jobData['salary'] = v ?? '',

                ),

                const SizedBox(height: 10),

                TextFormField(

                  decoration: InputDecoration(labelText: t('الوصف الوظيفي', 'Job Description')),

                  maxLines: 4,

                  onSaved: (v) => jobData['description'] = v ?? '',

                ),

                const SizedBox(height: 20),

                ElevatedButton(

                  onPressed: () async {

                    if (_formKey.currentState!.validate()) {

                      _formKey.currentState!.save();

                      await FirebaseFirestore.instance.collection('jobs').add({

                        'title': jobData['title'],

                        'city': jobData['city'],

                        'country': jobData['country'],

                        'type': jobData['type'] ?? '',

                        'category': jobData['category'] ?? '',

                        'salary': jobData['salary'] ?? '',

                        'description': jobData['description'] ?? '',

                        'company': widget.companyName,

                        'companyId': widget.companyId, // ✅ ربط الوظيفة بالشركة

                        'createdAt': DateTime.now(),

                      });

                      ScaffoldMessenger.of(context).showSnackBar(

                        SnackBar(content: Text(t('تم نشر الوظيفة بنجاح ✅', 'Job published successfully ✅'))),

                      );

                      Navigator.pop(context);

                    }

                  },

                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),

                  child: Text(t('نشر الوظيفة', 'Publish Job')),

                ),

              ],

            ),

          ),

        ),

      ),

    );

  }

}