import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  String email = '';
  String fullname = '';
  String address = '';
  String profileImageUrl = '';
  String phone = '';
  bool isEditing = false;
  bool isLoading = false;
  TextEditingController fullnameController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      isLoading = true;
    });

    try {
      User? user = _auth.currentUser;
      if (user != null) {
        // Fetch data from the 'users' collection
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          Map<String, dynamic> userData =
              userDoc.data() as Map<String, dynamic>;
          setState(() {
            email = userData['email'] ?? '';
            fullname = userData['fullname'] ?? '';
            address = userData['address'] ?? '';
            phone = userData['phone'] ?? '';
            profileImageUrl = userData['profileImageUrl'] ?? '';
            fullnameController.text = fullname;
            addressController.text = address;
            phoneController.text = phone;
          });
        } else {
          // Create a new document in the 'users' collection if it doesn't exist
          await _firestore.collection('users').doc(user.uid).set({
            'email': user.email ?? '',
            'fullname': '',
            'address': '',
            'phone': '',
            'profileImageUrl': '',
          });
          setState(() {
            email = user.email ?? '';
          });
        }
      } else {
        throw Exception('No authenticated user found');
      }
    } catch (e) {
      _showErrorSnackBar('Failed to load profile: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _updateUserData() async {
    setState(() {
      isLoading = true;
    });

    try {
      User? user = _auth.currentUser;
      if (user != null) {
        // Update the 'users' collection with the edited data
        await _firestore.collection('users').doc(user.uid).update({
          'fullname': fullnameController.text,
          'address': addressController.text,
          'phone': phoneController.text,
        });

        // Update the local state
        setState(() {
          fullname = fullnameController.text;
          address = addressController.text;
          phone = phoneController.text;
          isEditing = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
      } else {
        throw Exception('No authenticated user found');
      }
    } catch (e) {
      _showErrorSnackBar('Failed to update profile: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _pickAndUploadImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        isLoading = true;
      });

      try {
        File file = File(image.path);
        User? user = _auth.currentUser;
        if (user != null) {
          String fileName =
              'profile_${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';
          Reference storageRef =
              _storage.ref().child('profile_images/$fileName');

          // Upload the file
          await storageRef.putFile(file);

          // Get the download URL
          String downloadURL = await storageRef.getDownloadURL();

          // Update the 'users' collection with the new profile image URL
          await _firestore.collection('users').doc(user.uid).update({
            'profileImageUrl': downloadURL,
          });

          setState(() {
            profileImageUrl = downloadURL;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Profile picture updated successfully')),
          );
        } else {
          throw Exception('No authenticated user found');
        }
      } catch (e) {
        _showErrorSnackBar('Failed to update profile picture: $e');
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color.fromARGB(255, 173, 205, 204),
              const Color.fromARGB(255, 180, 152, 225)
            ],
          ),
        ),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : CustomScrollView(
                slivers: [
                  SliverAppBar(
                    expandedHeight: 200.0,
                    floating: false,
                    pinned: true,
                    flexibleSpace: Container(
                      child: FlexibleSpaceBar(
                        background: profileImageUrl.isNotEmpty
                            ? Container(
                                child: CachedNetworkImage(
                                  imageUrl: profileImageUrl,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    color: Colors.grey[300],
                                    child: const Center(
                                        child: CircularProgressIndicator()),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.error),
                                ),
                              )
                            : Container(
                                color: Theme.of(context).primaryColor,
                                child: const Center(
                                  child: Icon(Icons.person,
                                      size: 80, color: Colors.white),
                                ),
                              ),
                      ),
                    ),
                    actions: [
                      IconButton(
                        icon: Icon(isEditing ? Icons.save : Icons.edit),
                        onPressed: isLoading
                            ? null
                            : () {
                                if (isEditing) {
                                  _updateUserData();
                                } else {
                                  setState(() {
                                    isEditing = true;
                                  });
                                }
                              },
                      ),
                    ],
                  ),
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        Text(fullname,
                                style: const TextStyle(
                                    fontSize: 30, fontWeight: FontWeight.bold))
                            .animate()
                            .fadeIn(duration: 500.ms),
                        ElevatedButton.icon(
                          onPressed: isLoading ? null : _pickAndUploadImage,
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('Change Profile Picture'),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Theme.of(context).primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                          ),
                        ).animate().scale(duration: 300.ms),
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  _buildInfoField(
                                    icon: Icons.email,
                                    label: 'Email',
                                    controller: TextEditingController(
                                        text: email), // Use controller
                                    isEditable: false,
                                  ),
                                  const SizedBox(height: 15),
                                  _buildInfoField(
                                    icon: Icons.person,
                                    label: 'Full Name',
                                    controller:
                                        fullnameController, // Use controller
                                    isEditable: isEditing,
                                  ),
                                  const SizedBox(height: 15),
                                  _buildInfoField(
                                    icon: Icons.home,
                                    label: 'Address',
                                    controller:
                                        addressController, // Use controller
                                    isEditable: isEditing,
                                  ),
                                  const SizedBox(height: 15),
                                  _buildInfoField(
                                    icon: Icons.contact_phone,
                                    label: 'Phone Number',
                                    controller:
                                        phoneController, // Use controller
                                    isEditable: isEditing,
                                  ),
                                ],
                              ),
                            ).animate().fadeIn(duration: 500.ms).slide(),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: isLoading
                              ? null
                              : () async {
                                  await _auth.signOut();
                                  Navigator.of(context)
                                      .pushReplacementNamed('/login');
                                },
                          icon: const Icon(Icons.logout),
                          label: const Text('Sign Out'),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                          ),
                        ).animate().scale(duration: 300.ms),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildInfoField({
    required IconData icon,
    required String label,
    TextEditingController? controller,
    bool isEditable = true,
  }) {
    return TextFormField(
      controller: controller, // Use only the controller
      readOnly: !isEditable,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
              color: Theme.of(context).primaryColor.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
              BorderSide(color: Theme.of(context).primaryColor, width: 2),
        ),
      ),
    );
  }
}
