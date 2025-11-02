// lib/pages/add_company_page.dart

import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:provider/provider.dart';

import '../providers/language_provider.dart';

class AddCompanyPage extends StatefulWidget {

  const AddCompanyPage({super.key});

  @override

  State<AddCompanyPage> createState() => _AddCompanyPageState();

}

class _AddCompanyPageState extends State<AddCompanyPage> {

  final _formKey = GlobalKey<FormState>();

  final Map<String, String> companyData = {};

  @override

  Widget build(BuildContext context) {

    final isAr = Provider.of<LanguageProvider>(context).isArabic;

    String t(String ar, String en) => isAr ? ar : en;

    return Directionality(

      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,

      child: Scaffold(

        appBar: AppBar(title: Text(t('تسجيل شركة جديدة', 'Register New Company')), backgroundColor: Colors.blue),

        body: Padding(

          padding: const EdgeInsets.all(16),

          child: Form(

            key: _formKey,

            child: ListView(

              children: [

                TextFormField(

                  decoration: InputDecoration(labelText: t('اسم الشركة', 'Company Name')),

                  validator: (v) => v!.isEmpty ? t('مطلوب', 'Required') : null,

                  onSaved: (v) => companyData['name'] = v!,

                ),

                const SizedBox(height: 10),

                TextFormField(

                  decoration: InputDecoration(labelText: t('الدولة', 'Country')),

                  validator: (v) => v!.isEmpty ? t('مطلوب', 'Required') : null,

                  onSaved: (v) => companyData['country'] = v!,

                ),

                const SizedBox(height: 10),

                TextFormField(

                  decoration: InputDecoration(labelText: t('المدينة', 'City')),

                  validator: (v) => v!.isEmpty ? t('مطلوب', 'Required') : null,

                  onSaved: (v) => companyData['city'] = v!,

                ),

                const SizedBox(height: 10),

                TextFormField(

                  decoration: InputDecoration(labelText: t('وصف مختصر', 'Short Description')),

                  maxLines: 3,

                  onSaved: (v) => companyData['description'] = v ?? '',

                ),

                const SizedBox(height: 20),

                ElevatedButton(

                  onPressed: () async {

                    if (_formKey.currentState!.validate()) {

                      _formKey.currentState!.save();

                      final doc = await FirebaseFirestore.instance.collection('companies').add({

                        ...companyData,

                        'createdAt': DateTime.now(),

                      });

                      ScaffoldMessenger.of(context).showSnackBar(

                        SnackBar(content: Text(t('تم تسجيل الشركة بنجاح ✅', 'Company registered successfully ✅'))),

                      );

                      Navigator.pop(context, {

                        'companyId': doc.id,

                        'companyName': companyData['name'],

                      });

                    }

                  },

                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),

                  child: Text(t('تسجيل الشركة', 'Register Company')),

                ),

              ],

            ),

          ),

        ),

      ),

    );

  }

}