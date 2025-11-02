import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';

import 'package:google_sign_in/google_sign_in.dart';

class AuthProvider extends ChangeNotifier {

  final FirebaseAuth _auth = FirebaseAuth.instance;

  final FirebaseFirestore _fire = FirebaseFirestore.instance;

  User? get user => _auth.currentUser;

  bool get isSignedIn => user != null;

  Map<String, dynamic>? _userData;

  Map<String, dynamic>? get userData => _userData;

  bool get isCompany => _userData?['role'] == 'company';

  bool get isJobSeeker => _userData?['role'] == 'jobseeker';

  AuthProvider() {

    _auth.authStateChanges().listen((u) async {

      if (u != null) {

        await _loadUserData(u.uid);

      } else {

        _userData = null;

      }

      notifyListeners();

    });

  }

  Future<void> _loadUserData(String uid) async {

    try {

      final doc = await _fire.collection('users').doc(uid).get();

      _userData = doc.exists ? doc.data() : null;

    } catch (e) {

      debugPrint('⚠️ Error loading user data: $e');

    }

  }

  Future<void> signOut() async {

    await _auth.signOut();

    await GoogleSignIn().signOut();

    _userData = null;

    notifyListeners();

  }

  /// ✅ تسجيل الدخول بواسطة Google

  Future<UserCredential?> signInWithGoogle({String role = 'jobseeker'}) async {

    try {

      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) return null;

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(

        accessToken: googleAuth.accessToken,

        idToken: googleAuth.idToken,

      );

      final userCred = await _auth.signInWithCredential(credential);

      await _createOrUpdateUser(userCred.user!, role: role);

      await _loadUserData(userCred.user!.uid);

      notifyListeners();

      return userCred;

    } catch (e) {

      debugPrint('⚠️ Google sign in error: $e');

      rethrow;

    }

  }

  /// 🟢 إنشاء أو تحديث بيانات المستخدم في Firestore

  Future<void> _createOrUpdateUser(User u, {String role = 'jobseeker'}) async {

    final docRef = _fire.collection('users').doc(u.uid);

    final snapshot = await docRef.get();

    final data = {

      'uid': u.uid,

      'email': u.email,

      'name': u.displayName ?? '',

      'photoUrl': u.photoURL ?? '',

      'role': role,

      'createdAt': FieldValue.serverTimestamp(),

    };

    if (!snapshot.exists) {

      await docRef.set(data);

    } else {

      await docRef.update({

        'email': u.email ?? '',

        'name': u.displayName ?? '',

        'photoUrl': u.photoURL ?? '',

      });

    }

  }

  /// 🏢 تسجيل شركة جديدة

  Future<void> registerCompanyProfile(

      String uid, Map<String, dynamic> companyData) async {

    await _fire.collection('companies').doc(uid).set(companyData);

    await _fire.collection('users').doc(uid).update({'role': 'company'});

    await _loadUserData(uid);

    notifyListeners();

  }

  /// 📧 تسجيل الدخول بالبريد الإلكتروني

  Future<UserCredential?> signInWithEmail(

      String email, String password) async {

    try {

      final userCred = await _auth.signInWithEmailAndPassword(

        email: email,

        password: password,

      );

      await _loadUserData(userCred.user!.uid);

      notifyListeners();

      return userCred;

    } catch (e) {

      debugPrint('⚠️ Email sign in error: $e');

      rethrow;

    }

  }

  /// 🆕 إنشاء حساب بالبريد الإلكتروني

  Future<UserCredential?> registerWithEmail(

    String email,

    String password,

    String name, {

    String role = 'jobseeker',

  }) async {

    try {

      final userCred = await _auth.createUserWithEmailAndPassword(

        email: email,

        password: password,

      );

      final user = userCred.user!;

      await _fire.collection('users').doc(user.uid).set({

        'uid': user.uid,

        'email': email,

        'name': name,

        'photoUrl': '',

        'role': role,

        'createdAt': FieldValue.serverTimestamp(),

      });

      await _loadUserData(user.uid);

      notifyListeners();

      return userCred;

    } catch (e) {

      debugPrint('⚠️ Email registration error: $e');

      rethrow;

    }

  }

  /// ❌ حذف الحساب نهائياً

  Future<void> deleteAccount() async {

    final uid = user?.uid;

    if (uid != null) {

      await _fire.collection('users').doc(uid).delete();

      await user!.delete();

      _userData = null;

      notifyListeners();

    }

  }

}