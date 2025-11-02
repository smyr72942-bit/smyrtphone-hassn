import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:google_sign_in/google_sign_in.dart';

class LoginPage extends StatelessWidget {

  const LoginPage({super.key});

  Future<UserCredential> signInWithGoogle() async {

    final googleUser = await GoogleSignIn().signIn();

    final googleAuth = await googleUser?.authentication;

    final credential = GoogleAuthProvider.credential(

      accessToken: googleAuth?.accessToken,

      idToken: googleAuth?.idToken,

    );

    return await FirebaseAuth.instance.signInWithCredential(credential);

  }

  @override

  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: Colors.white,

      body: Center(

        child: Padding(

          padding: const EdgeInsets.all(24.0),

          child: Column(

            mainAxisAlignment: MainAxisAlignment.center,

            children: [

              const Text("فرصك", style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.blue)),

              const SizedBox(height: 10),

              const Text("أفضل تطبيق وظائف عربي", style: TextStyle(fontSize: 16)),

              const SizedBox(height: 40),

              ElevatedButton.icon(

                style: ElevatedButton.styleFrom(

                  backgroundColor: Colors.blue,

padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),

                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),

                ),

                icon: const Icon(Icons.login, color: Colors.white),

                label: const Text("تسجيل الدخول عبر Google", style: TextStyle(color: Colors.white, fontSize: 18)),

                onPressed: () async {

                  await signInWithGoogle();

                },

              ),

            ],

          ),

        ),

      ),

    );

  }

}