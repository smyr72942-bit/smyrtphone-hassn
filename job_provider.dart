import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class JobProvider extends ChangeNotifier {

  List<Map<String, dynamic>> _jobs = [];

  List<Map<String, dynamic>> _filteredJobs = [];

  // فلاتر مختارة

  String? selectedCountry;

  String? selectedCity;

  String? selectedCategory;

  String? selectedJobType; // ← توحيد الاسم مع main.dart

  String? selectedSalaryRange;

  String _searchText = '';

  // مدن عربية حسب الدولة

  Map<String, List<String>> arabCities = {

    'العراق': ['بغداد', 'البصرة', 'نينوى', 'أربيل', 'النجف', 'كربلاء', 'ذي قار', 'صلاح الدين', 'ديالى', 'الأنبار', 'بابل', 'كركوك', 'واسط', 'المثنى', 'ميسان', 'دهوك', 'السليمانية', 'القادسية'],

    'السعودية': ['الرياض', 'جدة', 'مكة', 'المدينة', 'الدمام', 'الخبر', 'أبها'],

    'مصر': ['القاهرة', 'الإسكندرية', 'المنصورة', 'أسوان', 'سوهاج', 'طنطا'],

    'الإمارات': ['دبي', 'أبوظبي', 'الشارقة', 'العين', 'رأس الخيمة'],

    'الكويت': ['مدينة الكويت', 'حولي', 'الفروانية', 'الجهراء'],

    'قطر': ['الدوحة', 'الوكرة', 'الريان'],

    'الأردن': ['عمان', 'إربد', 'الزرقاء', 'الكرك'],

    'لبنان': ['بيروت', 'طرابلس', 'صيدا', 'زحلة'],

    'عمان': ['مسقط', 'صلالة', 'نزوى'],

    'البحرين': ['المنامة', 'المحرق', 'سترة'],

    'الجزائر': ['الجزائر العاصمة', 'وهران', 'قسنطينة', 'عنابة'],

    'تونس': ['تونس', 'صفاقس', 'سوسة'],

    'المغرب': ['الرباط', 'الدار البيضاء', 'فاس', 'مراكش'],

    'اليمن': ['صنعاء', 'عدن', 'تعز', 'الحديدة'],

    'فلسطين': ['رام الله', 'غزة', 'نابلس', 'الخليل'],

    'السودان': ['الخرطوم', 'أم درمان', 'بحري'],

    'ليبيا': ['طرابلس', 'بنغازي', 'مصراتة'],

  };

  // فئات الوظائف

  List<String> jobTypes = ['دوام كامل', 'دوام جزئي', 'عمل حر', 'تدريب'];

  List<String> categories = ['تكنولوجيا', 'تصميم', 'مبيعات', 'خدمات', 'إدارة', 'تدريس'];

  List<String> salaryRanges = ['<500$', '500-1000$', '1000-2000$', '>2000$'];

  List<Map<String, dynamic>> get filteredJobs => _filteredJobs;

  List<String> get countries => arabCities.keys.toList();

  List<String> citiesByCountry(String country) => arabCities[country] ?? [];

  // 🔹 جلب الوظائف من Firebase

  Future<void> fetchJobsFromFirestore() async {

    try {

      final snapshot = await FirebaseFirestore.instance.collection('jobs').get();

      _jobs = snapshot.docs.map((doc) {

        final data = doc.data();

        return {

          'title': data['title'] ?? '',

          'company': data['company'] ?? '',

          'city': data['city'] ?? '',

          'country': data['country'] ?? '',

          'category': data['category'] ?? '',

          'jobType': data['jobType'] ?? '',

          'salary': data['salary'] ?? '',

          'salaryRange': data['salaryRange'] ?? '',

        };

      }).toList();

      _filteredJobs = List.from(_jobs);

      notifyListeners();

    } catch (e) {

      print("⚠️ خطأ أثناء جلب الوظائف: $e");

      rethrow;

    }

  }

  // 🔹 إضافة وظيفة جديدة

  Future<void> addJob(Map<String, dynamic> job) async {

    try {

      await FirebaseFirestore.instance.collection('jobs').add(job);

      _jobs.add(job);

      _applyFilters();

    } catch (e) {

      print("⚠️ خطأ أثناء إضافة الوظيفة: $e");

    }

  }

  // 🔹 تطبيق الفلاتر + البحث النصي

  void applyFilters({

    String? country,

    String? city,

    String? category,

    String? jobType,

    String? salaryRange,

    String searchText = '',

  }) {

    selectedCountry = country;

    selectedCity = city;

    selectedCategory = category;

    selectedJobType = jobType;

    selectedSalaryRange = salaryRange;

    _searchText = searchText;

    _applyFilters();

  }

  // 🔹 مسح الفلاتر

  void clearFilters() {

    selectedCountry = null;

    selectedCity = null;

    selectedCategory = null;

    selectedJobType = null;

    selectedSalaryRange = null;

    _searchText = '';

    _filteredJobs = List.from(_jobs);

    notifyListeners();

  }

  // 🔹 منطق الفلترة الداخلي + البحث

  void _applyFilters() {

    final lowerText = _searchText.toLowerCase();

    _filteredJobs = _jobs.where((job) {

      final matchCountry = selectedCountry == null || job['country'] == selectedCountry;

      final matchCity = selectedCity == null || job['city'] == selectedCity;

      final matchCategory = selectedCategory == null || job['category'] == selectedCategory;

      final matchJobType = selectedJobType == null || job['jobType'] == selectedJobType;

      final matchSalary = selectedSalaryRange == null || job['salaryRange'] == selectedSalaryRange;

      final matchText = lowerText.isEmpty ||

          job['title'].toString().toLowerCase().contains(lowerText) ||

          job['company'].toString().toLowerCase().contains(lowerText);

      return matchCountry && matchCity && matchCategory && matchJobType && matchSalary && matchText;

    }).toList();

    notifyListeners();

  }

  // 🔹 اقتراح وظيفة عشوائية

  Map<String, dynamic>? getJobSuggestion() {

    if (_jobs.isEmpty) return null;

    _jobs.shuffle();

    return _jobs.first;

  }

}