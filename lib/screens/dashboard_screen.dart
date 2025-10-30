import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/member_model.dart';
import 'add_member_screen.dart';
import 'member_detail_screen.dart';
import 'profile_screen.dart'; // ✅ Profile Screen import

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  String _searchQuery = '';

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // ✅ Navigate to Profile page when user taps Profile tab
    if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ProfileScreen()),
      );
    }
  }

  Future<void> _navigateToAddMember() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddMemberScreen()),
    );
  }

  // 🔹 Home Page (Main Dashboard)
  Widget _buildHome() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(
        child: Text("Please log in to view your members."),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔹 Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Gym Freek",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.redAccent,
                ),
              ),
              SizedBox(
                height: 60,
                width: 60,
                child: Lottie.asset(
                  'assets/animations/gym_member.json',
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),

          // 🔹 Profile Button (like your snippet)
          // GestureDetector(
          //   onTap: () {
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(builder: (_) => const ProfileScreen()),
          //     );
          //   },
          //   child: Container(
          //     padding: const EdgeInsets.all(16),
          //     decoration: BoxDecoration(
          //       color: Colors.deepPurple,
          //       borderRadius: BorderRadius.circular(10),
          //     ),
          //     child: const Row(
          //       mainAxisAlignment: MainAxisAlignment.center,
          //       children: [
          //         Icon(Icons.person, color: Colors.white),
          //         SizedBox(width: 10),
          //         Text(
          //           "Profile",
          //           style: TextStyle(
          //               color: Colors.white,
          //               fontSize: 18,
          //               fontWeight: FontWeight.bold),
          //         ),
          //       ],
          //     ),
          //   ),
          // ),

          const SizedBox(height: 20),

          // 🔹 Search Bar
          TextField(
            decoration: InputDecoration(
              hintText: "Search member by name...",
              prefixIcon: const Icon(Icons.search, color: Colors.redAccent),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.redAccent, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (val) {
              setState(() {
                _searchQuery = val.toLowerCase();
              });
            },
          ),
          const SizedBox(height: 10),

          // 🔹 Members List (from Firestore)
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .collection('members')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      "No members yet. Tap + to add.",
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  );
                }

                final members = snapshot.data!.docs.where((doc) {
                  final name = doc['name'].toString().toLowerCase();
                  return name.contains(_searchQuery);
                }).toList();

                if (members.isEmpty) {
                  return const Center(
                    child: Text(
                      "No matching member found.",
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: members.length,
                  itemBuilder: (context, index) {
                    final data = members[index].data() as Map<String, dynamic>;
                    final member = MemberModel.fromMap(data);

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                MemberDetailsScreen(member: member),
                          ),
                        );
                      },
                      child: Card(
                        elevation: 3,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundImage: member.imagePath.isNotEmpty
                                ? FileImage(File(member.imagePath))
                                : const AssetImage('assets/default_user.png')
                            as ImageProvider,
                          ),
                          title: Text(
                            member.name,
                            style:
                            const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            "Age: ${member.age} | Weight: ${member.weight} kg",
                            style: const TextStyle(fontSize: 13),
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: Colors.redAccent,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // 🔹 Floating Add Button
          Align(
            alignment: Alignment.bottomRight,
            child: FloatingActionButton(
              onPressed: _navigateToAddMember,
              backgroundColor: Colors.redAccent,
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  static const List<Widget> _navPages = [
    Icon(Icons.home, size: 100, color: Colors.redAccent),
    Icon(Icons.calendar_month, size: 100, color: Colors.redAccent),
    Icon(Icons.person, size: 100, color: Colors.redAccent),
    Icon(Icons.fitness_center, size: 100, color: Colors.redAccent),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _selectedIndex == 0
          ? _buildHome()
          : Center(child: _navPages[_selectedIndex]),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.redAccent,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.event_available), label: "Attendance"),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline), label: "Profile"),
          BottomNavigationBarItem(
              icon: Icon(Icons.fitness_center), label: "Exercise"),
        ],
      ),
    );
  }
}
