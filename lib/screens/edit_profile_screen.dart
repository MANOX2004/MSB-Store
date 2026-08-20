import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  bool _isLoading = false;

  Uint8List? _imageBytes;
  String? _currentPhotoData;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // ඩේටාබේස් එකෙන් දැනට තියෙන නම සහ ෆොටෝ එක ලබා ගැනීම
  Future<void> _loadUserData() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      _nameController.text = currentUser.displayName ?? '';

      // Firestore එකෙන් ඩේටා ලබා ගැනීම
      var doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();
      if (doc.exists && doc.data() != null) {
        setState(() {
          _currentPhotoData = doc.data()!['profileImageUrl'] ?? '';
        });
      }
    }
  }

  // ගැලරියෙන් පින්තූරයක් තෝරා ගැනීම
  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        var bytes = await image.readAsBytes();
        setState(() {
          _imageBytes = bytes;
        });
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  // ප්‍රොෆයිල් එක නොමිලේ සේව් කිරීම (Firestore හරහා)
  Future<void> _saveProfile() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      String finalPhotoData = _currentPhotoData ?? '';

      // යූසර් අලුතින් පින්තූරයක් තෝරා ඇත්නම් එය Base64 string එකක් බවට හැරවීම
      if (_imageBytes != null) {
        String base64String = base64Encode(_imageBytes!);
        finalPhotoData = 'data:image/jpeg;base64,$base64String';
      }

      String updatedName = _nameController.text.trim();

      // 1. Firebase Authentication එකේ නම අප්ඩේට් කිරීම
      await currentUser.updateDisplayName(updatedName);
      await currentUser.reload();

      // 2. Firestore Database එකේ 'users' collection එකට නම සහ Base64 Image string එක සේව් කිරීම
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .set({
            'name': updatedName,
            'profileImageUrl': finalPhotoData,
          }, SetOptions(merge: true));

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      print('Error updating profile: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // පින්තූරය (MemoryImage හෝ NetworkImage) නිවැරදිව පෙන්වීම සඳහා
    ImageProvider? getBackgroundImage() {
      if (_imageBytes != null) {
        return MemoryImage(_imageBytes!);
      } else if (_currentPhotoData != null && _currentPhotoData!.isNotEmpty) {
        if (_currentPhotoData!.startsWith('data:image')) {
          try {
            final split = _currentPhotoData!.split(',');
            if (split.length > 1) {
              return MemoryImage(base64Decode(split[1]));
            }
          } catch (e) {
            print('Error decoding base64: $e');
          }
        }
        return NetworkImage(_currentPhotoData!);
      }
      return null;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 20),
              Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.amber[700],
                    backgroundImage: getBackgroundImage(),
                    child: getBackgroundImage() == null
                        ? Icon(Icons.person, size: 70, color: Colors.white)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      backgroundColor: Colors.amber[800],
                      radius: 18,
                      child: IconButton(
                        icon: Icon(
                          Icons.camera_alt,
                          size: 16,
                          color: Colors.white,
                        ),
                        onPressed: _pickImage,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              TextButton.icon(
                onPressed: _pickImage,
                icon: Icon(Icons.image, color: Colors.amber[700]),
                label: Text(
                  'Choose Profile Picture',
                  style: TextStyle(
                    color: Colors.amber[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 30),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person, color: Colors.amber[700]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.amber.shade700,
                      width: 2,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber[700],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _isLoading ? null : _saveProfile,
                  child: _isLoading
                      ? SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Save Changes',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
