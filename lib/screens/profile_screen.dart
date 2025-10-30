import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final user = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  File? _posterImage;
  File? _profileImage;

  String? posterUrl;
  String? profileUrl;
  String gymName = '';
  String address = '';
  String fees = '';
  String certificates = '';
  String medals = '';
  String ownerName = '';

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final doc = await _firestore.collection('gyms').doc(user!.uid).get();
    if (doc.exists) {
      final data = doc.data()!;
      setState(() {
        posterUrl = data['posterUrl'];
        profileUrl = data['profileUrl'];
        gymName = data['gymName'] ?? '';
        address = data['address'] ?? '';
        fees = data['fees'] ?? '';
        certificates = data['certificates'] ?? '';
        medals = data['medals'] ?? '';
        ownerName = data['ownerName'] ?? '';
      });
    }
  }

  Future<void> _pickImage(bool isPoster) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        if (isPoster) {
          _posterImage = File(picked.path);
        } else {
          _profileImage = File(picked.path);
        }
      });
      await _uploadImage(File(picked.path), isPoster);
    }
  }

  Future<void> _uploadImage(File imageFile, bool isPoster) async {
    final ref = FirebaseStorage.instance
        .ref()
        .child('gym_images')
        .child('${user!.uid}_${isPoster ? 'poster' : 'profile'}.jpg');

    await ref.putFile(imageFile);
    final downloadUrl = await ref.getDownloadURL();

    await _firestore.collection('gyms').doc(user!.uid).set({
      isPoster ? 'posterUrl' : 'profileUrl': downloadUrl,
    }, SetOptions(merge: true));

    setState(() {
      if (isPoster) {
        posterUrl = downloadUrl;
      } else {
        profileUrl = downloadUrl;
      }
    });
  }

  Future<void> _saveDetails() async {
    await _firestore.collection('gyms').doc(user!.uid).set({
      'gymName': gymName,
      'address': address,
      'fees': fees,
      'certificates': certificates,
      'medals': medals,
      'ownerName': ownerName,
      'posterUrl': posterUrl,
      'profileUrl': profileUrl,
    }, SetOptions(merge: true));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Gym Freek",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Poster Image
            GestureDetector(
              onTap: () => _pickImage(true),
              child: Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  image: DecorationImage(
                    image: posterUrl != null
                        ? NetworkImage(posterUrl!)
                        : _posterImage != null
                        ? FileImage(_posterImage!)
                        : const AssetImage('assets/images/default_poster.jpg')
                    as ImageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
                child: const Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Icon(Icons.camera_alt, color: Colors.white, size: 28),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Profile Image
            GestureDetector(
              onTap: () => _pickImage(false),
              child: CircleAvatar(
                radius: 55,
                backgroundImage: profileUrl != null
                    ? NetworkImage(profileUrl!)
                    : _profileImage != null
                    ? FileImage(_profileImage!)
                    : const AssetImage('assets/images/default_profile.png')
                as ImageProvider,
                child: const Align(
                  alignment: Alignment.bottomRight,
                  child: CircleAvatar(
                    radius: 15,
                    backgroundColor: Colors.black,
                    child: Icon(Icons.camera_alt, color: Colors.white, size: 16),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),

            _buildTextField("Gym Name", gymName, (v) => gymName = v),
            _buildTextField("Address", address, (v) => address = v),
            _buildTextField("Membership Fees", fees, (v) => fees = v),
            _buildTextField("Certificates", certificates, (v) => certificates = v),
            _buildTextField("Medals", medals, (v) => medals = v),
            _buildTextField("Owner Name", ownerName, (v) => ownerName = v),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: _saveDetails,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 40),
              ),
              child: const Text(
                "Save Details",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String initial, Function(String) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        initialValue: initial,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
