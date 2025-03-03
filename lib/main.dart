import 'package:clinic_users/api/firebase_options.dart';
import 'package:clinic_users/features/queue/widgets/bottom_nav_bar.dart';
import 'package:clinic_users/features/appointment/pages/tabs/appointment_page.dart';
import 'package:clinic_users/features/auth/pages/status_page.dart';
import 'package:clinic_users/features/dashboard/home_page.dart';
import 'package:clinic_users/features/medical_record/medical_record_page.dart';

import 'package:clinic_users/features/profile/profile_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

void main() async {
  if (kDebugMode) {
    print('Starting the app');
  }
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.android,
  );
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  // Obtain the FCM token
  String? token = await messaging.getToken();
  if (kDebugMode) {
    print("FCM Token: $token");
  }

  // Handle foreground messages
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    if (kDebugMode) {
      print('Received a message while in the foreground!');
    }
    if (message.notification != null) {
      if (kDebugMode) {
        print('Message Title: ${message.notification!.title}');
      }
      if (kDebugMode) {
        print('Message Body: ${message.notification!.body}');
      }
    }
  });

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const StatusPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final _pages = [
    const HomePage(),
    AppointmentPage(),
    const ProfilePage(),
    MedicalReportPage(),
  ];

  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
      body: _pages[_selectedIndex] as Widget?,
    );
  }
}
