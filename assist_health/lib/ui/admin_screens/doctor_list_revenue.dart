import 'package:assist_health/others/theme.dart';
import 'package:assist_health/ui/admin_screens/doctor_profile_add.dart';
import 'package:assist_health/ui/admin_screens/doctor_profile_detail.dart';
import 'package:assist_health/ui/admin_screens/doctor_profile_update.dart';
import 'package:assist_health/ui/admin_screens/revenue_doctor_chart.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DoctorListRevenue extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: Text('Danh sách Bác sĩ',
        style: TextStyle(fontSize: 20),
        ),
        centerTitle: true,
         flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Themes.gradientDeepClr, Themes.gradientLightClr],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),  
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
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
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
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DoctorRevenueChartScreen(
                  doctorId: doctor.id,
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
}
 