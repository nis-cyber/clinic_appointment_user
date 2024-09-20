import 'package:clinic_users/features/profile/user_service.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final UserService _userService = UserService();
  Map<String, dynamic>? userDetails;

  @override
  void initState() {
    super.initState();
    _loadUserDetails();
  }

  Future<void> _loadUserDetails() async {
    try {
      var userSnapshot = await _userService.getUserDetails();
      setState(() {
        userDetails = userSnapshot.data();
      });
    } catch (e) {
      print('Error loading user details: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Page'),
      ),
      body: userDetails == null
          ? const Center(
              child:
                  CircularProgressIndicator()) // Show a loader until data is fetched
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(userDetails!['profile'] ??
                          'https://via.placeholder.com/150'),
                    ),
                  ),
                  Text(
                    'Full Name: ${userDetails!['fullname'] ?? 'Not available'}',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Email: ${userDetails!['email'] ?? 'Not available'}',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Address: ${userDetails!['address'] ?? 'Not available'}',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
    );
  }
}
