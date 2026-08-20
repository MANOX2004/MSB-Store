import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _firestoreImageUrl;
  String? _firestoreName;
  bool _isLoadingData = false;

  @override
  void initState() {
    super.initState();
    _fetchUserDataFromFirestore();
  }

  Future<void> _fetchUserDataFromFirestore() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    setState(() {
      _isLoadingData = true;
    });

    try {
      var doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();
      if (doc.exists && doc.data() != null) {
        setState(() {
          _firestoreImageUrl = doc.data()!['profileImageUrl'];
          _firestoreName = doc.data()!['name'];
        });
      }
    } catch (e) {
      print('Error fetching user data from Firestore: $e');
    } finally {
      setState(() {
        _isLoadingData = false;
      });
    }
  }

  void _navigateToEditProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditProfileScreen()),
    ).then((_) {
      setState(() {});
      _fetchUserDataFromFirestore();
    });
  }

  @override
  Widget build(BuildContext context) {
    User? currentUser = FirebaseAuth.instance.currentUser;
    final colorScheme = Theme.of(context).colorScheme;

    ImageProvider? getProfileImage() {
      if (_firestoreImageUrl != null && _firestoreImageUrl!.isNotEmpty) {
        if (_firestoreImageUrl!.startsWith('data:image')) {
          try {
            final split = _firestoreImageUrl!.split(',');
            if (split.length > 1) {
              return MemoryImage(base64Decode(split[1]));
            }
          } catch (e) {
            print('Error decoding base64 image: $e');
          }
        }
        return NetworkImage(_firestoreImageUrl!);
      }

      if (currentUser?.photoURL != null && currentUser!.photoURL!.isNotEmpty) {
        return NetworkImage(currentUser.photoURL!);
      }

      return null;
    }

    String displayName = '';
    if (_firestoreName != null && _firestoreName!.isNotEmpty) {
      displayName = _firestoreName!;
    } else if (currentUser?.displayName != null &&
        currentUser!.displayName!.isNotEmpty) {
      displayName = currentUser.displayName!;
    } else {
      displayName = 'No Name Set';
    }

    ImageProvider? profileImageProvider = getProfileImage();

    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoadingData
            ? const Center(child: CircularProgressIndicator())
            : currentUser == null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.account_circle,
                      size: 90,
                      color: Colors.amber[800],
                    ),
                    SizedBox(height: 16),
                    Text(
                      'You are not logged in!',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Please login to view your profile details and orders.',
                      style: TextStyle(color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber[700],
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LoginScreen(),
                          ),
                        ).then((_) {
                          setState(() {});
                          _fetchUserDataFromFirestore();
                        });
                      },
                      child: Text(
                        'Login / Register',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : Column(
                children: [
                  SizedBox(height: 20),
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.amber[700],
                          backgroundImage: profileImageProvider,
                          child: profileImageProvider == null
                              ? Icon(
                                  Icons.person,
                                  size: 60,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    displayName,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 6),
                  Text(
                    currentUser.email ?? '',
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: 30),

                  Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: Icon(
                        Icons.manage_accounts,
                        color: Colors.amber[700],
                      ),
                      title: Text(
                        'Edit Profile',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Colors.grey,
                      ),
                      onTap: _navigateToEditProfile,
                    ),
                  ),
                  SizedBox(height: 10),

                  Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: Icon(Icons.email, color: Colors.amber[700]),
                      title: Text(
                        'Email Address',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(currentUser.email ?? 'N/A'),
                    ),
                  ),
                  Spacer(),
                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                        setState(() {
                          _firestoreImageUrl = null;
                          _firestoreName = null;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Logged out successfully!')),
                        );
                      },
                      child: Text(
                        'Log Out',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
      ),
    );
  }
}
