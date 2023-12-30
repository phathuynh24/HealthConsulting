// ignore_for_file: avoid_print

import 'package:assist_health/ui/admin_screens/doctor_profile_add.dart';
import 'package:assist_health/ui/admin_screens/doctor_profile_detail.dart';
import 'package:assist_health/ui/admin_screens/doctor_profile_update.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DoctorProfileList extends StatelessWidget {
  const DoctorProfileList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách Bác sĩ'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: 'doctor')
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasData) {
            final doctors = snapshot.data!.docs;
            return ListView.builder(
              itemCount: doctors.length,
              itemBuilder: (context, index) {
                var doctor = doctors[index];
                return _buildDoctorItem(context, doctor);
              },
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddDoctorScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildDoctorItem(BuildContext context, QueryDocumentSnapshot doctor) {
    final data = doctor.data() as Map<String, dynamic>?;
    final name =
        data != null && data.containsKey('name') ? data['name'] as String : '';
    final imageURL = data != null && data.containsKey('imageURL')
        ? data['imageURL'] as String
        : '';
    final specialties = data != null && data.containsKey('specialty')
        ? (data['specialty'] is String
            ? [data['specialty'] as String]
            : List<String>.from(data['specialty']))
        : [];
    List<Widget> specialtyChips = [];
    for (var specialty in specialties) {
      specialtyChips.add(
        Chip(
            label: Text(
          specialty,
          style: const TextStyle(fontSize: 12.0),
        )),
      );
    }
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: _buildAvatarImage(imageURL),
        ),
        title: Text(name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8.0),
            const Text('Chuyên ngành:'),
            const SizedBox(height: 8.0),
            SizedBox(
              height: 40.0,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: specialtyChips,
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                _navigateToUpdatePage(context, doctor);
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                _showDeleteConfirmationDialog(context, doctor.id, data?['uid']);
              },
            ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DoctorProfileDetailScreen(
                doctorUid: data?['uid'],
              ),
            ),
          );
        },
      ),
    );
  }

  ImageProvider<Object> _buildAvatarImage(String imageURL) {
    if (imageURL.isNotEmpty) {
      return NetworkImage(imageURL);
    } else {
      return const AssetImage('assets/doctor1.jpg');
    }
  }

  void _showDeleteConfirmationDialog(
      BuildContext context, String doctorId, String? doctorUid) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xác nhận xóa bác sĩ'),
          content: const Text('Bạn có chắc chắn muốn xóa bác sĩ này?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                _deleteDoctor(doctorId, doctorUid);
                Navigator.of(context).pop();
              },
              child: const Text('Xóa'),
            ),
          ],
        );
      },
    );
  }

  void _navigateToUpdatePage(
      BuildContext context, QueryDocumentSnapshot doctor) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UpdateDoctorScreen(doctorId: doctor.id),
      ),
    );
  }

  void _deleteDoctor(String doctorId, String? doctorUid) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(doctorId)
          .delete();
      if (doctorUid != null) {
        await FirebaseAuth.instance.currentUser!.delete();
      }
    } catch (e) {
      print('Error deleting doctor: $e');
    }
  }
}
