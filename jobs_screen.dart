import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'providers/job_provider.dart';

import 'job_details_page.dart';

class JobsScreen extends StatefulWidget {

  const JobsScreen({super.key});

  @override

  State<JobsScreen> createState() => _JobsScreenState();

}

class _JobsScreenState extends State<JobsScreen> {

  final TextEditingController _searchController = TextEditingController();

  @override

  void initState() {

    super.initState();

    Provider.of<JobProvider>(context, listen: false).fetchJobsFromFirestore();

  }

  @override

  Widget build(BuildContext context) {

    final jobProvider = Provider.of<JobProvider>(context);

    return Scaffold(

      appBar: AppBar(

        title: const Text("الوظائف المتاحة"),

        actions: [

          IconButton(

            icon: const Icon(Icons.refresh),

            onPressed: () {

              jobProvider.resetFilters();

              _searchController.clear();

            },

          ),

        ],

      ),

      body: Column(

        children: [

          // 🔍 البحث

          Padding(

            padding: const EdgeInsets.all(8.0),

            child: TextField(

              controller: _searchController,

              decoration: const InputDecoration(

                labelText: "ابحث عن وظيفة...",

                prefixIcon: Icon(Icons.search),

                border: OutlineInputBorder(),

              ),

              onChanged: (value) => jobProvider.updateKeyword(value),

            ),

          ),

          // 🧠 الفلاتر

          SingleChildScrollView(

            scrollDirection: Axis.horizontal,

            padding: const EdgeInsets.symmetric(horizontal: 8),

            child: Row(

              children: [

                _buildDropdown(

                  label: "النوع",

                  value: jobProvider.selectedType,

                  items: [

                    "دوام كامل",

                    "دوام جزئي",

                    "دوام مؤقت",

                    "عمل حر",

                    "موسمي",

                    "تدريب",

                    "عن بُعد",

                    "دوام مرن"

                  ],

                  onChanged: jobProvider.updateType,

                ),

                _buildDropdown(

                  label: "المدينة",

                  value: jobProvider.selectedCity,

                  items: [

                    "بغداد",

                    "البصرة",

                    "أربيل",

                    "النجف",

                    "كربلاء",

                    "السعودية",

                    "الإمارات",

                    "الكويت",

                    "قطر",

                    "البحرين",

                    "عمان"

                  ],

                  onChanged: jobProvider.updateCity,

                ),

                _buildDropdown(

                  label: "الفئة",

                  value: jobProvider.selectedCategory,

                  items: ["تكنولوجيا", "صحة", "تعليم", "إدارة", "خدمة عملاء"],

                  onChanged: jobProvider.updateCategory,

                ),

                _buildDropdown(

                  label: "الراتب",

                  value: jobProvider.selectedSalaryRange,

                  items: [

                    "أقل من 500",

                    "من 500 إلى 1000",

                    "من 1000 إلى 2000",

                    "من 2000 إلى مليون",

                    "أكثر من مليونين"

                  ],

                  onChanged: jobProvider.updateSalaryRange,

                ),

              ],

            ),

          ),

          const SizedBox(height: 10),

          // 📋 عرض الوظائف

          Expanded(

            child: jobProvider.filteredJobs.isEmpty

                ? const Center(child: Text("لا توجد وظائف مطابقة"))

                : ListView.builder(

                    itemCount: jobProvider.filteredJobs.length,

                    itemBuilder: (context, index) {

                      final job = jobProvider.filteredJobs[index];

                      return Card(

                        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),

                        child: ListTile(

                          title: Text(job['title'] ?? "بدون عنوان"),

                          subtitle: Text("${job['company']} - ${job['city']}"),

                          trailing: const Icon(Icons.arrow_forward_ios),

                          onTap: () {

                            Navigator.push(

                              context,

                              MaterialPageRoute(

                                builder: (_) => JobDetailsPage(job: job),

                              ),

                            );

                          },

                        ),

                      );

                    },

                  ),

          ),

        ],

      ),

    );

  }

  Widget _buildDropdown({

    required String label,

    required String? value,

    required List<String> items,

    required void Function(String?) onChanged,

  }) {

    return Padding(

      padding: const EdgeInsets.symmetric(horizontal: 6),

      child: DropdownButton<String>(

        value: value,

        hint: Text(label),

        items: items.map((item) {

          return DropdownMenuItem(value: item, child: Text(item));

        }).toList(),

        onChanged: onChanged,

      ),

    );

  }

}