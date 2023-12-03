import 'package:assist_health/others/theme.dart';
import 'package:assist_health/others/methods.dart';
import 'package:assist_health/models/doctor/doctor_info.dart';
import 'package:assist_health/ui/user_screens/detail_doctor.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DoctorListScreen extends StatefulWidget {
  const DoctorListScreen({super.key});

  @override
  State<DoctorListScreen> createState() => _DoctorListScreenState();
}

class _DoctorListScreenState extends State<DoctorListScreen> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Themes.backgroundClr,
      appBar: AppBar(
        title: const Text('Danh sách bác sĩ'),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Themes.leftClr, Themes.rightClr],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            FutureBuilder<List<DoctorInfo>>(
              future: getInfoDoctors(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const SizedBox(
                      height: 290,
                      width: double.infinity,
                      child: Center(
                        child: Text('Something went wrong'),
                      ));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                      height: 290,
                      width: double.infinity,
                      child: Center(
                        child: SizedBox(
                          height: 40,
                          width: 40,
                          child: CircularProgressIndicator(),
                        ),
                      ));
                }

                return Container(
                  height: 400,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 10,
                  ),
                  child: ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage:
                              NetworkImage(snapshot.data![index].image),
                        ),
                        title: Text(
                          snapshot.data![index].name,
                        ),
                        subtitle: Text(snapshot.data![index].expert),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => DetailDoctorScreen(
                                      snapshot.data![index])));
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
