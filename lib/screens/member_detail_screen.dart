import 'dart:io';
import 'package:flutter/material.dart';
import '../models/member_model.dart';

class MemberDetailsScreen extends StatelessWidget {
  final MemberModel member;

  const MemberDetailsScreen({super.key, required this.member});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(member.name),
        backgroundColor: Colors.redAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 60,
                backgroundImage: member.imagePath.isNotEmpty
                    ? FileImage(File(member.imagePath))
                    : const AssetImage('assets/default_user.png') as ImageProvider,
              ),
            ),
            const SizedBox(height: 20),
            Text('Name: ${member.name}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Age: ${member.age}', style: const TextStyle(fontSize: 18)),
            Text('Weight: ${member.weight} kg', style: const TextStyle(fontSize: 18)),
            Text('Height: ${member.height}', style: const TextStyle(fontSize: 18)),
            Text('Fees: ₹${member.fees}', style: const TextStyle(fontSize: 18, color: Colors.green)),
          ],
        ),
      ),
    );
  }
}
