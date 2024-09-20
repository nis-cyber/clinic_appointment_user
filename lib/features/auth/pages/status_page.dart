import 'package:clinic_users/features/auth/pages/login_page.dart';
import 'package:clinic_users/features/dashboard/home_page.dart';
import 'package:clinic_users/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class StatusPage extends StatelessWidget {
  const StatusPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // user is logged in
          if (snapshot.hasData) {
            return MainPage();
          } else {
            return LoginPage();
          }

          // user is not logged in
        },
      ),
    );
  }
}
