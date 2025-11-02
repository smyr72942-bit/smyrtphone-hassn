import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';

class JobService with ChangeNotifier {

  final FirebaseFirestore _fire = FirebaseFirestore.instance;

  List<Map<String, dynamic>> _jobs = [];

  List<Map<String, dynamic>> get jobs => _jobs;

  bool loading = false;

  /// 🔹 جلب كل الوظائف

  Future<void> fetchAllJobs() async {

    loading = true;

    notifyListeners();

    try {

      final snap = await _fire

          .collection('jobs')

          .orderBy('createdAt', descending: true)

          .get();

      _jobs = snap.docs.map((d) {

        final data = d.data();

        data['id'] = d.id;

        return data;

      }).toList();

    } catch (e) {

      debugPrint('⚠️ fetchAllJobs error: $e');

    }

    loading = false;

    notifyListeners();

  }

  /// 🟢 إضافة وظيفة جديدة

  Future<void> addJob(Map<String, dynamic> job) async {

    try {

      final doc = await _fire.collection('jobs').add({

        ...job,

        'createdAt': FieldValue.serverTimestamp(),

      });

      final snapshot = await doc.get();

      final map = snapshot.data()!;

      map['id'] = snapshot.id;

      _jobs.insert(0, map);

      notifyListeners();

    } catch (e) {

      debugPrint('⚠️ addJob error: $e');

      rethrow;

    }

  }

  /// ✏️ تحديث وظيفة

  Future<void> updateJob(String id, Map<String, dynamic> updated) async {

    try {

      await _fire.collection('jobs').doc(id).update(updated);

      final idx = _jobs.indexWhere((j) => j['id'] == id);

      if (idx != -1) {

        _jobs[idx] = {..._jobs[idx], ...updated};

        notifyListeners();

      }

    } catch (e) {

      debugPrint('⚠️ updateJob error: $e');

    }

  }

  /// 🗑️ حذف وظيفة

  Future<void> deleteJob(String id) async {

    try {

      await _fire.collection('jobs').doc(id).delete();

      _jobs.removeWhere((j) => j['id'] == id);

      notifyListeners();

    } catch (e) {

      debugPrint('⚠️ deleteJob error: $e');

    }

  }

  /// 🤖 اقتراحات ذكية

  List<Map<String, dynamic>> suggestJobs({

    String? city,

    String? country,

    String? category,

    String? text,

    int limit = 10,

  }) {

    final lower = (text ?? '').toLowerCase();

    return _jobs.where((j) {

      final matchesCity = city == null || j['city'] == city;

      final matchesCountry = country == null || j['country'] == country;

      final matchesCat = category == null || j['category'] == category;

      final matchesText = lower.isEmpty ||

          j['title'].toString().toLowerCase().contains(lower) ||

          j['company'].toString().toLowerCase().contains(lower) ||

          (j['description']?.toString().toLowerCase().contains(lower) ?? false);

      return matchesCity && matchesCountry && matchesCat && matchesText;

    }).take(limit).toList();

  }

  /// 🔍 البحث في الوظائف

  List<Map<String, dynamic>> searchJobs(String keyword) {

    final lower = keyword.toLowerCase();

    return _jobs.where((j) {

      return j['title'].toString().toLowerCase().contains(lower) ||

          j['company'].toString().toLowerCase().contains(lower) ||

          (j['description']?.toString().toLowerCase().contains(lower) ?? false);

    }).toList();

  }

  /// 🆔 جلب وظيفة واحدة حسب ID

  Map<String, dynamic>? getJobById(String id) {

    return _jobs.firstWhere((j) => j['id'] == id, orElse: () => {});

  }

  /// 🗺️ جلب المدن والفئات

  List<String> getCities() =>

      _jobs.map((j) => j['city']?.toString() ?? '').toSet().toList();

  List<String> getCountries() =>

      _jobs.map((j) => j['country']?.toString() ?? '').toSet().toList();

  List<String> getCategories() =>

      _jobs.map((j) => j['category']?.toString() ?? '').toSet().toList();

  List<String> getTypes() =>

      _jobs.map((j) => j['jobType']?.toString() ?? '').toSet().toList();

}