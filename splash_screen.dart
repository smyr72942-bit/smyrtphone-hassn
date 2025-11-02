import 'package:flutter/material.dart';

import 'dart:async';

import 'main.dart'; // حتى يقدر يدخل على AuthGate بعد الانتهاء

class SplashScreen extends StatefulWidget {

  const SplashScreen({super.key});

  @override

  State<SplashScreen> createState() => _SplashScreenState();

}

class _SplashScreenState extends State<SplashScreen> {

  @override

  void initState() {

    super.initState();

    // الانتقال بعد 2 ثانية إلى AuthGate

    Timer(const Duration(seconds: 2), () {

      Navigator.pushReplacement(

        context,

        MaterialPageRoute(builder: (_) => const AuthGate()),

      );

    });

  }

  @override

  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: Colors.indigo.shade50,

      body: Center(

        child: Column(

          mainAxisAlignment: MainAxisAlignment.center,

          children: [

            // شعار التطبيق (تقدر تضيف لوجو لاحقاً)

            const Icon(

              Icons.work_outline_rounded,

              color: Colors.indigo,

              size: 80,

            ),

            const SizedBox(height: 20),

            const Text(

              "فرصك Fursak",

              style: TextStyle(

                fontSize: 32,

                fontWeight: FontWeight.bold,

                color: Colors.indigo,

              ),

            ),

            const SizedBox(height: 10),

            const Text(

              "ذكاء العمل يبدأ من هنا 💼🤖",

              style: TextStyle(

                fontSize: 16,

                color: Colors.black54,

              ),

            ),

            const SizedBox(height: 40),

            const CircularProgressIndicator(color: Colors.indigo),

          ],

        ),

      ),

    );

  }

}