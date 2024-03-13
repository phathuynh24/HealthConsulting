// ignore_for_file: avoid_print

import 'dart:async';

import 'package:assist_health/src/models/doctor/doctor_info.dart';
import 'package:assist_health/src/others/methods.dart';
import 'package:assist_health/src/others/theme.dart';
import 'package:assist_health/src/presentation/screens/user_screens/doctor_detail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class FavoriteDoctorList extends StatefulWidget {
  const FavoriteDoctorList({super.key});

  @override
  State<FavoriteDoctorList> createState() => _FavoriteDoctorListState();
}

class _FavoriteDoctorListState extends State<FavoriteDoctorList> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  StreamController<List<DoctorInfo>>? _doctorInfoController =
      StreamController<List<DoctorInfo>>.broadcast();

  List<String> favoriteUidDoctors = [];
  List<String> uidFavorite = [];

  bool isDeleteDoctor = false;

  List<bool> checkboxValues = [];

  @override
  void initState() {
    super.initState();
    fetchFavoriteUidDoctors();
    _doctorInfoController!.addStream(getInfoDoctors());
  }

  Future<void> fetchFavoriteUidDoctors() async {
    final QuerySnapshot snapshot = await _firestore
        .collection('favorite_doctor')
        .where('currentUid', isEqualTo: _auth.currentUser!.uid)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final List<String> fetchedFavoriteUidDoctors =
          snapshot.docs.map((doc) => doc['uidDoctor'] as String).toList();
      final List<String> fetchUidFavorite =
          snapshot.docs.map((doc) => doc.id).toList();

      setState(() {
        uidFavorite = fetchUidFavorite;

        favoriteUidDoctors = fetchedFavoriteUidDoctors;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: const Text(
          'Danh sách bác sĩ quan tâm',
          style: TextStyle(fontSize: 18),
        ),
        elevation: 0,
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
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_square),
            onPressed: () {
              setState(() {
                isDeleteDoctor = !isDeleteDoctor;
              });
            },
          ),
        ],
      ),
      body: StreamBuilder<List<DoctorInfo>>(
        stream: _doctorInfoController!.stream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Đã xảy ra lỗi: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          List<DoctorInfo> filterDoctor = snapshot.data!.toList();

          List<DoctorInfo> filterDoctorFavorite = [];
          filterDoctorFavorite = filterDoctor
              .where((doctor) => favoriteUidDoctors.contains(doctor.uid))
              .toList();

          // Sắp xếp bác sĩ yêu thích theo danh sách thời gian like
          filterDoctorFavorite.sort((a, b) {
            final indexA = favoriteUidDoctors.indexOf(a.uid);
            final indexB = favoriteUidDoctors.indexOf(b.uid);
            return indexA.compareTo(indexB);
          });

          // Xử lý không tìm ra kết quả
          if (filterDoctorFavorite.isEmpty) {
            return SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                height: 350,
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/empty-box.png',
                      width: 250,
                      height: 250,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    const Text(
                      'Bạn chưa theo dõi bác sĩ nào',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(
                      height: 6,
                    ),
                    const Text(
                      'Thêm bác sĩ vào danh sách quan tâm để đặt khám nhanh hơn',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blueGrey,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return Container(
            color: Colors.blueAccent.withOpacity(0.1),
            child: ListView.builder(
              itemCount: filterDoctorFavorite.length,
              itemBuilder: (context, index) {
                DoctorInfo doctor = filterDoctorFavorite[index];
                checkboxValues.add(false);
                return Container(
                  height: 90,
                  margin: const EdgeInsets.symmetric(vertical: 0.5),
                  decoration: const BoxDecoration(color: Colors.white),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      DoctorDetailScreen(doctorInfo: doctor)));
                        },
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.only(
                                      top: 10, left: 20, bottom: 10),
                                  margin: const EdgeInsets.only(
                                    right: 10,
                                  ),
                                  width: 85,
                                  height: 85,
                                  child: ClipOval(
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Themes.gradientDeepClr,
                                            Themes.gradientLightClr
                                          ],
                                          begin: Alignment.bottomCenter,
                                          end: Alignment.topCenter,
                                        ),
                                      ),
                                      child: (doctor.imageURL != '')
                                          ? Image.network(doctor.imageURL,
                                              fit: BoxFit.cover, errorBuilder:
                                                  (BuildContext context,
                                                      Object exception,
                                                      StackTrace? stackTrace) {
                                              return const Center(
                                                child: Icon(
                                                  FontAwesomeIcons.userDoctor,
                                                  size: 40,
                                                  color: Colors.white,
                                                ),
                                              );
                                            })
                                          : Center(
                                              child: Text(
                                                getAbbreviatedName(doctor.name),
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 200,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      (doctor.careerTitiles.isNotEmpty)
                                          ? Text(
                                              doctor.careerTitiles,
                                              style: const TextStyle(
                                                color: Colors.black54,
                                                fontSize: 15,
                                                height: 1.5,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            )
                                          : const SizedBox(),
                                      Text(
                                        doctor.name,
                                        style: const TextStyle(
                                          color: Colors.black87,
                                          fontSize: 15,
                                          height: 1.5,
                                          fontWeight: FontWeight.bold,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Spacer(),
                                isDeleteDoctor
                                    ? Container(
                                        height: 90,
                                        padding: const EdgeInsets.all(10),
                                        color:
                                            Colors.blueAccent.withOpacity(0.11),
                                        child: Checkbox(
                                            value: checkboxValues[index],
                                            onChanged: (value) {
                                              setState(() {
                                                checkboxValues[index] =
                                                    !checkboxValues[index];
                                              });
                                            }),
                                      )
                                    : const SizedBox(),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
      bottomNavigationBar: checkboxValues.contains(true)
          ? Container(
              height: 70,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Colors.blueGrey,
                    width: 0.2,
                  ),
                ),
              ),
              child: GestureDetector(
                onTap: () {
                  List<int> trueIndexes = checkboxValues
                      .toList()
                      .asMap()
                      .entries
                      .where((entry) => entry.value == true)
                      .map((entry) => entry.key)
                      .toList();
                  for (var element in trueIndexes) {
                    deleteFavoriteDoctor(favoriteUidDoctors[element]);
                    setState(() {
                      favoriteUidDoctors.removeAt(element);
                      checkboxValues.removeAt(element);
                    });
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(13),
                  margin: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'Xóa khỏi danh sách',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            )
          : const SizedBox(),
    );
  }

  void deleteFavoriteDoctor(String uidDoctor) {
    _firestore
        .collection('favorite_doctor')
        .where('currentUid', isEqualTo: _auth.currentUser!.uid)
        .where('uidDoctor', isEqualTo: uidDoctor)
        .limit(1)
        .get()
        .then((QuerySnapshot snapshot) {
      if (snapshot.docs.isNotEmpty) {
        snapshot.docs.first.reference.delete().then((value) {
          print('Favorite doctor deleted successfully!');
        }).catchError((error) {
          print('Failed to delete favorite doctor: $error');
        });
      } else {
        print('No matching favorite doctor found.');
      }
    }).catchError((error) {
      print('Failed to retrieve favorite doctor: $error');
    });
  }
}
