import 'dart:async';

import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:google_sign_in/google_sign_in.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:provider/provider.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:flutter_localizations/flutter_localizations.dart';

// ✅ استيرادات صحيحة لمسارات الملفات

import 'providers/job_provider.dart';

import 'providers/language_provider.dart';

import 'screens/company_dashboard.dart';

import 'screens/cv_analysis.dart';

import 'screens/store_dashboard.dart';

import 'screens/auth_gate.dart';

import 'screens/login_page.dart';

// ✅ إشعارات محلية + Firebase Messaging

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =

    FlutterLocalNotificationsPlugin();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  _showLocalNotification(message);

}

Future<void> _showLocalNotification(RemoteMessage message) async {

  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(

    'fursak_channel',

    'Fursak Notifications',

    importance: Importance.max,

    priority: Priority.high,

    playSound: true,

  );

  const NotificationDetails platformDetails =

      NotificationDetails(android: androidDetails);

  await flutterLocalNotificationsPlugin.show(

    0,

    message.notification?.title ?? 'فرصك',

    message.notification?.body ?? '',

    platformDetails,

  );

}

Future<void> _initNotifications() async {

  const AndroidInitializationSettings initializationSettingsAndroid =

      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings =

      InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  FirebaseMessaging messaging = FirebaseMessaging.instance;

  await messaging.requestPermission();

  FirebaseMessaging.onMessage.listen(_showLocalNotification);

}

// ✅ تشغيل التطبيق

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(

    options: DefaultFirebaseOptions.currentPlatform,

  );

  await _initNotifications();

  runApp(const FursakApp());

}

// ✅ البنية الأساسية للتطبيق

class FursakApp extends StatelessWidget {

  const FursakApp({super.key});

  @override

  Widget build(BuildContext context) {

    return MultiProvider(

      providers: [

        ChangeNotifierProvider(create: (_) => JobProvider()),

        ChangeNotifierProvider(create: (_) => LanguageProvider()),

      ],

      child: const MainApp(),

    );

  }

}

// ✅ التطبيق الرئيسي

class MainApp extends StatelessWidget {

  const MainApp({super.key});

  @override

  Widget build(BuildContext context) {

    final lang = Provider.of<LanguageProvider>(context);

    return MaterialApp(

      debugShowCheckedModeBanner: false,

      title: 'فرصك Fursak',

      locale: lang.currentLocale,

      supportedLocales: const [Locale('ar'), Locale('en')],

      localizationsDelegates: const [

        GlobalMaterialLocalizations.delegate,

        GlobalWidgetsLocalizations.delegate,

        GlobalCupertinoLocalizations.delegate,

      ],

      theme: ThemeData(

        fontFamily:

            lang.currentLocale.languageCode == 'ar' ? 'Tajawal' : 'Roboto',

        primarySwatch: Colors.indigo,

      ),

      home: const SplashScreen(),

    );

  }

}

/////////////////////////////////////

// ✅ شاشة البداية

/////////////////////////////////////

class SplashScreen extends StatefulWidget {

  const SplashScreen({super.key});

  @override

  State<SplashScreen> createState() => _SplashScreenState();

}

class _SplashScreenState extends State<SplashScreen> {

  @override

  void initState() {

    super.initState();

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

          children: const [

            Icon(Icons.work_outline_rounded, color: Colors.indigo, size: 80),

            SizedBox(height: 20),

            Text(

              "فرصك Fursak",

              style: TextStyle(

                fontSize: 32,

                fontWeight: FontWeight.bold,

                color: Colors.indigo,

              ),

            ),

            SizedBox(height: 10),

            Text(

              "ذكاء العمل يبدأ من هنا 💼🤖",

              style: TextStyle(fontSize: 16, color: Colors.black54),

            ),

            SizedBox(height: 40),

            CircularProgressIndicator(color: Colors.indigo),

          ],

        ),

      ),

    );

  }

}

/////////////////////////////////////

// ✅ الصفحة الرئيسية

/////////////////////////////////////

class HomePage extends StatefulWidget {

  const HomePage({super.key});

  @override

  State<HomePage> createState() => _HomePageState();

}

class _HomePageState extends State<HomePage> {

  @override

  void initState() {

    super.initState();

    Provider.of<JobProvider>(context, listen: false).fetchJobsFromFirestore();

  }

  void openCompanyDashboard() {

    Navigator.push(

      context,

      MaterialPageRoute(

        builder: (_) => const CompanyDashboard(companyName: "Fursak Company"),

      ),

    );

  }

  void openStoreDashboard() {

    Navigator.push(

      context,

      MaterialPageRoute(

        builder: (_) => const StoreDashboard(storeName: "Fursak Store"),

      ),

    );

  }

  Future<void> smartApply(Map<String, dynamic> job) async {

    final aiMessage = """

مرحباً ${job['company']},

أنا مهتم جداً بوظيفة ${job['title']} في ${job['city']} براتب ${job['salary']} د.ع.

لدي خبرة عملية قوية وأتعهد بالالتزام والجودة.

مع التحية،

مرشح من تطبيق فرصك 🔵

""";

    ScaffoldMessenger.of(context).showSnackBar(

      SnackBar(content: Text("تم التقديم تلقائياً على ${job['title']}")),

    );

    await flutterLocalNotificationsPlugin.show(

      0,

      "تم التقديم ✅",

      aiMessage,

      const NotificationDetails(

        android: AndroidNotificationDetails(

          'fursak_channel',

          'Fursak Notifications',

          importance: Importance.max,

          priority: Priority.high,

          playSound: true,

        ),

      ),

    );

  }

  @override

  Widget build(BuildContext context) {

    final provider = Provider.of<JobProvider>(context);

    final lang = Provider.of<LanguageProvider>(context);

    final isArabic = lang.currentLocale.languageCode == 'ar';

    return Scaffold(

      appBar: AppBar(

        title: Text(isArabic ? 'فرصك Fursak' : 'Fursak Jobs'),

        backgroundColor: Colors.indigo,

        actions: [

          IconButton(

              icon: const Icon(Icons.language),

              onPressed: () => lang.toggleLanguage()),

          IconButton(

              icon: const Icon(Icons.business),

              onPressed: openCompanyDashboard),

          IconButton(icon: const Icon(Icons.store), onPressed: openStoreDashboard),

          IconButton(

              icon: const Icon(Icons.file_present),

              onPressed: () => Navigator.push(

                    context,

                    MaterialPageRoute(builder: (_) => const CvAnalysisPage()),

                  )),

          IconButton(

              icon: const Icon(Icons.logout),

              onPressed: () => FirebaseAuth.instance.signOut()),

        ],

      ),

      body: Column(

        children: [

          const SizedBox(height: 8),

          const FilterSection(),

          const SizedBox(height: 8),

          Padding(

            padding: const EdgeInsets.symmetric(horizontal: 12),

            child: TextField(

              decoration: const InputDecoration(

                hintText: 'ابحث عن وظيفة...',

                prefixIcon: Icon(Icons.search),

                border: OutlineInputBorder(),

              ),

              onChanged: (text) {

                provider.applyFilters(searchText: text);

              },

            ),

          ),

          const SizedBox(height: 8),

          Expanded(

            child: provider.filteredJobs.isEmpty

                ? Center(

                    child: Text(

                        isArabic ? 'لا توجد وظائف حالياً' : 'No jobs available now'),

                  )

                : ListView.builder(

                    itemCount: provider.filteredJobs.length,

                    itemBuilder: (context, index) {

                      final job = provider.filteredJobs[index];

                      return Card(

                        margin: const EdgeInsets.all(8),

                        child: ListTile(

                          title: Text(job['title']),

                          subtitle: Text("${job['company']} - ${job['city']}"),

                          trailing: IconButton(

                            icon: const Icon(Icons.flash_on, color: Colors.indigo),

                            onPressed: () => smartApply(job),

                          ),

                        ),

                      );

                    },

                  ),

          ),

        ],

      ),

    );

  }

}

/////////////////////////////////////

// ✅ قسم الفلاتر

/////////////////////////////////////

class FilterSection extends StatelessWidget {

  const FilterSection({super.key});

  @override

  Widget build(BuildContext context) {

    final provider = Provider.of<JobProvider>(context);

    return SingleChildScrollView(

      scrollDirection: Axis.horizontal,

      padding: const EdgeInsets.symmetric(horizontal: 8),

      child: Row(

        children: [

          DropdownButton<String>(

            hint: const Text("الدولة"),

            value: provider.selectedCountry,

            items: provider.countries

                .map((country) =>

                    DropdownMenuItem(value: country, child: Text(country)))

                .toList(),

            onChanged: (value) => provider.applyFilters(country: value),

          ),

          const SizedBox(width: 8),

          DropdownButton<String>(

            hint: const Text("المدينة"),

            value: provider.selectedCity,

            items: (provider.selectedCountry != null

                    ? provider.citiesByCountry(provider.selectedCountry!)

                    : <String>[])

                .map((city) => DropdownMenuItem(value: city, child: Text(city)))

                .toList(),

            onChanged: (value) => provider.applyFilters(city: value),

          ),

          const SizedBox(width: 8),

          DropdownButton<String>(

            hint: const Text("نوع الوظيفة"),

            value: provider.selectedJobType,

            items: provider.jobTypes

                .map((type) =>

                    DropdownMenuItem(value: type, child: Text(type)))

                .toList(),

            onChanged: (value) => provider.applyFilters(jobType: value),

          ),

          const SizedBox(width: 8),

          DropdownButton<String>(

            hint: const Text("الفئة"),

            value: provider.selectedCategory,

            items: provider.categories

                .map((cat) =>

                    DropdownMenuItem(value: cat, child: Text(cat)))

                .toList(),

            onChanged: (value) => provider.applyFilters(category: value),

          ),

          const SizedBox(width: 8),

          DropdownButton<String>(

            hint: const Text("الراتب"),

            value: provider.selectedSalaryRange,

            items: provider.salaryRanges

                .map((range) =>

                    DropdownMenuItem(value: range, child: Text(range)))

                .toList(),

            onChanged: (value) => provider.applyFilters(salaryRange: value),

          ),

          const SizedBox(width: 8),

          IconButton(

            icon: const Icon(Icons.clear, color: Colors.red),

            onPressed: provider.clearFilters,

          ),

        ],

      ),

    );

  }

}