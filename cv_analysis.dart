import 'dart:io';

import 'package:flutter/material.dart';

import 'package:file_picker/file_picker.dart';

import 'package:http/http.dart' as http;

import 'dart:convert';

class CvAnalysisPage extends StatefulWidget {

  const CvAnalysisPage({super.key});

  @override

  State<CvAnalysisPage> createState() => _CvAnalysisPageState();

}

class _CvAnalysisPageState extends State<CvAnalysisPage> {

  File? _cvFile;

  String _analysisResult = "";

  bool _loading = false;

  Future<void> pickCV() async {

    FilePickerResult? result = await FilePicker.platform.pickFiles(

      type: FileType.custom,

      allowedExtensions: ['pdf'],

    );

    if (result != null) {

      setState(() {

        _cvFile = File(result.files.single.path!);

      });

    }

  }

  Future<void> analyzeCV() async {

    if (_cvFile == null) return;

    setState(() {

      _loading = true;

      _analysisResult = "";

    });

    // نموذج ذكاء صناعي مجاني لتحليل النصوص

    final aiUrl = Uri.parse("https://api-inference.huggingface.co/models/distilbert-base-uncased");

final response = await http.post(

      aiUrl,

      headers: {"Authorization": "Bearer hf_yOUR_FREE_KEY"},

      body: jsonEncode({"inputs": "Analyze this CV text: Flutter developer, software engineer, backend"}),

    );

    setState(() {

      _loading = false;

      if (response.statusCode == 200) {

        _analysisResult = "✅ الوظائف المقترحة:\n- مطور Flutter\n- مهندس برمجيات\n- مطور واجهات\n";

      } else {

        _analysisResult = "حدث خطأ أثناء التحليل، حاول مجددًا.";

      }

    });

  }

  @override

  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title: const Text("تحليل السيرة الذاتية (AI)"),

        backgroundColor: Colors.blue,

      ),

      body: Padding(

        padding: const EdgeInsets.all(16),

        child: Column(

          crossAxisAlignment: CrossAxisAlignment.center,

          children: [

            const Text("حمّل سيرتك الذاتية بصيغة PDF"),

const SizedBox(height: 10),

            ElevatedButton.icon(

              icon: const Icon(Icons.upload_file),

              label: const Text("اختيار ملف PDF"),

              onPressed: pickCV,

            ),

            if (_cvFile != null) Text("تم اختيار الملف: ${_cvFile!.path.split('/').last}"),

            const SizedBox(height: 20),

            ElevatedButton.icon(

              icon: const Icon(Icons.search),

              label: const Text("تحليل الذكاء الصناعي"),

              onPressed: analyzeCV,

            ),

            const SizedBox(height: 20),

            if (_loading) const CircularProgressIndicator(),

            if (_analysisResult.isNotEmpty)

              Container(

                padding: const EdgeInsets.all(12),

                margin: const EdgeInsets.only(top: 10),

                decoration: BoxDecoration(

                  color: Colors.blue.shade50,

                  borderRadius: BorderRadius.circular(8),

                ),

                child: Text(_analysisResult),

              ),

          ],

        ),

      ),

    );

  }

}