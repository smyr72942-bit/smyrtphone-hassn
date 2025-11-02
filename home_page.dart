import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:provider/provider.dart';

import '../providers/job_provider.dart';

import '../providers/language_provider.dart';

import 'filter_page.dart'; // تأكد من وجود هذه الصفحة

class HomePage extends StatelessWidget {

  const HomePage({super.key});

  @override

  Widget build(BuildContext context) {

    final provider = Provider.of<JobProvider>(context);

    final languageProvider = Provider.of<LanguageProvider>(context);

    final isArabic = languageProvider.isArabic;

    return Scaffold(

      appBar: AppBar(

        title: Text(isArabic ? 'فرصك' : 'Fursak'),

        actions: [

          // زر الفلترة 🔍

          IconButton(

            icon: const Icon(Icons.filter_list),

            onPressed: () {

              Navigator.push(

                context,

                MaterialPageRoute(builder: (_) => const FilterPage()),

              );

            },

          ),

          // زر تبديل اللغة 🌐

          IconButton(

            icon: const Icon(Icons.language),

            onPressed: () {

              languageProvider.toggleLanguage();

            },

          ),

          // زر تسجيل الخروج 🔓

          IconButton(

            icon: const Icon(Icons.logout),

            onPressed: () => FirebaseAuth.instance.signOut(),

          ),

        ],

      ),

      body: provider.filteredJobs.isEmpty

          ? Center(child: Text(isArabic ? 'لا توجد وظائف حالياً' : 'No jobs available'))

          : ListView.builder(

              itemCount: provider.filteredJobs.length,

              itemBuilder: (context, index) {

                final job = provider.filteredJobs[index];

                return ListTile(

                  title: Text(job['title']),

                  subtitle: Text("${job['company']} - ${job['city']}"),

                  trailing: Text("${job['salary']} ${isArabic ? 'د.ع' : 'IQD'}"),

                );

              },

            ),

      floatingActionButton: FloatingActionButton(

        backgroundColor: Colors.blue,

        child: const Icon(Icons.add),

        onPressed: () {

          provider.addJob({

            'title': isArabic ? 'مندوب مبيعات' : 'Sales Representative',

            'company': 'شركة ABC',

            'city': 'بغداد',

            'salary': '700,000',

          });

        },

      ),

    );

  }

}