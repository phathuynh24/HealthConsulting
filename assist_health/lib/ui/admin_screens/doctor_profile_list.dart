import 'package:assist_health/ui/admin_screens/doctor_profile_add.dart';
import 'package:assist_health/ui/admin_screens/doctor_profile_detail.dart';
import 'package:assist_health/ui/admin_screens/doctor_profile_update.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DoctorProfileList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Danh sách Bác sĩ'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('users').where('role', isEqualTo: 'doctor').snapshots(),
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
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddDoctorScreen()),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildDoctorItem(BuildContext context, QueryDocumentSnapshot doctor) {
    final data = doctor.data() as Map<String, dynamic>?;
    final name = data != null && data.containsKey('name') ? data['name'] as String : '';
    final imageURL = data != null && data.containsKey('imageURL') ? data['imageURL'] as String : '';
    final specialties = data != null && data.containsKey('specialty')
        ? (data['specialty'] is String
            ? [data['specialty'] as String]
            : List<String>.from(data['specialty']))
        : [];
    List<Widget> specialtyChips = [];
    for (var specialty in specialties) {
      specialtyChips.add(
        Chip(label: Text(
          specialty,
          style: TextStyle(fontSize: 12.0),
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
            Text('Chuyên ngành:'),
            const SizedBox(height: 8.0),
            Container(
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
              icon: Icon(Icons.edit),
              onPressed: () {
                _navigateToUpdatePage(context, doctor);
              },
            ),
            IconButton(
              icon: Icon(Icons.delete),
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
              builder: (context) => DoctorDetailScreen(
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
      return AssetImage('assets/doctor1.jpg');
    }
  }

  void _showDeleteConfirmationDialog(BuildContext context, String doctorId, String? doctorUid) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Xác nhận xóa bác sĩ'),
          content: Text('Bạn có chắc chắn muốn xóa bác sĩ này?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                _deleteDoctor(doctorId, doctorUid);
                Navigator.of(context).pop();
              },
              child: Text('Xóa'),
            ),
          ],
        );
      },
    );
  }

  void _navigateToUpdatePage(BuildContext context, QueryDocumentSnapshot doctor) {
  final data = doctor.data() as Map<String, dynamic>;
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => UpdateDoctorScreen(doctorId: doctor.id),
    ),
  );
}


  void _deleteDoctor(String doctorId, String? doctorUid) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(doctorId).delete();
      if (doctorUid != null) {
        await FirebaseAuth.instance.currentUser!.delete();
      }
    } catch (e) {
      print('Error deleting doctor: $e');
    }
  }
}
