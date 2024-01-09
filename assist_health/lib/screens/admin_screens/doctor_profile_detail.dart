import 'package:assist_health/others/theme.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DoctorProfileDetailScreen extends StatelessWidget {
  final String doctorUid;

  const DoctorProfileDetailScreen({super.key, required this.doctorUid});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: const Text('Thông tin Bác sĩ',
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
      body: FutureBuilder<DocumentSnapshot>(
        future:
            FirebaseFirestore.instance.collection('users').doc(doctorUid).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(
              child: Text('No data found.'),
            );
          }

          var doctorData = snapshot.data!.data() as Map<String, dynamic>;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Display doctor's image
                if (doctorData['imageURL'] != null)
                  Center(
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(doctorData['imageURL']),
                      radius: 60,
                    ),
                  ),
                const SizedBox(height: 16),
                // Display other information with enhanced styling
                const Text(
                  'Tên Bác sĩ:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  doctorData['name'],
                  style: const TextStyle(
                    fontSize: 24,
                    color: Colors.blue, // Customize the text color
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Mô tả:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  doctorData['description'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Chuyên khoa:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  doctorData['specialty'].join(', '),
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.green, // Customize the text color
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Nơi công tác:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  doctorData['workplace'],
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Học vấn:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                for (var education in doctorData['educations'])
                  Text(
                    '- $education',
                    style: const TextStyle(fontSize: 16),
                  ),
                const SizedBox(height: 16),
                const Text(
                  'Kinh nghiệm làm việc:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                for (var experience in doctorData['experiences'])
                  Text(
                    '- $experience',
                    style: const TextStyle(fontSize: 16),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
