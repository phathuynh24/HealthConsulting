// ignore_for_file: avoid_print, file_names

import 'package:assist_health/models/doctor/doctor_experience.dart';
import 'package:assist_health/models/doctor/doctor_info.dart';
import 'package:assist_health/models/doctor/doctor_service.dart';
import 'package:assist_health/models/doctor/doctor_study.dart';
import 'package:assist_health/ui/other_ui/login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

FirebaseAuth _auth = FirebaseAuth.instance;
FirebaseFirestore _firestore = FirebaseFirestore.instance;

Future<User?> createAccount(
    String name, String email, String password, String phone) async {
  try {
    UserCredential userCrendetial = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);

    print("Account created Succesfull");

    userCrendetial.user!.updateDisplayName(name);

    await _firestore.collection('users').doc(_auth.currentUser!.uid).set({
      "name": name,
      "email": email,
      "phone": phone,
      "role": "user",
      "status": "unavalible",
      "uid": _auth.currentUser!.uid,
    });

    return userCrendetial.user;
  } catch (e) {
    print(e);
    return null;
  }
}

Future<User?> logIn(String email, String password) async {
  try {
    UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email, password: password);

    print("Login Sucessfull");
    _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .get()
        .then((value) => userCredential.user!.updateDisplayName(value['name']));

    return userCredential.user;
  } catch (e) {
    print(e);
    return null;
  }
}

Future logOut(BuildContext context) async {
  try {
    await _auth.signOut().then((value) {
      Navigator.push(
          context, MaterialPageRoute(builder: (_) => const LoginScreen()));
    });
  } catch (e) {
    print("error");
  }
}

Future<String> getUrl(String fileName) async {
  final ref = storage.ref().child('Doctors/$fileName');
  String url = await ref.getDownloadURL();
  return url;
}

Future<List<DoctorInfo>> getInfoDoctors() async {
  final doctorDocs = await _firestore
      .collection('users')
      .where('role', isEqualTo: 'doctor')
      .get();
  final doctorInfos = await Future.wait(doctorDocs.docs.map((doctorDoc) async {
    final infoRef = _firestore
        .collection('users')
        .doc(doctorDoc.id)
        .collection('info')
        .get();
    final doctorInfo = await infoRef
        .then((value) => DoctorInfo.fromJson(value.docs.first.data()));
    doctorInfo.image = await getUrl(doctorInfo.image);
    doctorInfo.uid = doctorDoc.id;

    return doctorInfo;
  }));
  return doctorInfos;
}

Future<List<DoctorExperience>> getDoctorExperiences(String uid) async {
  final selectedDoctorDocs =
      await _firestore.collection('users').where('uid', isEqualTo: uid).get();

  final doctorExperiences = <DoctorExperience>[];

  for (final doc in selectedDoctorDocs.docs) {
    final docRef = await _firestore
        .collection('users')
        .doc(doc.id)
        .collection('experience')
        .get();

    final listOfExperiences = docRef.docs.map((experienceDoc) {
      if (experienceDoc.exists) {
        final experienceData = experienceDoc.data();
        final doctorExperience = DoctorExperience.fromJson(experienceData);
        return doctorExperience;
      } else {
        return null;
      }
    }).whereType<DoctorExperience>();

    doctorExperiences.addAll(listOfExperiences);
  }

  return doctorExperiences;
}

Future<List<DoctorStudy>> getDoctorStudys(String uid) async {
  final selectedDoctorDocs =
      await _firestore.collection('users').where('uid', isEqualTo: uid).get();

  final doctorStudys = <DoctorStudy>[];

  for (final doc in selectedDoctorDocs.docs) {
    final docRef = await _firestore
        .collection('users')
        .doc(doc.id)
        .collection('study')
        .get();

    final listOfStudys = docRef.docs.map((studyDoc) {
      if (studyDoc.exists) {
        final studyDocData = studyDoc.data();
        final doctorExperience = DoctorStudy.fromJson(studyDocData);
        return doctorExperience;
      } else {
        return null;
      }
    }).whereType<DoctorStudy>();

    doctorStudys.addAll(listOfStudys);
  }

  return doctorStudys;
}

Future<List<DoctorService>> getDoctorServices(String uid) async {
  final selectedDoctorDocs =
      await _firestore.collection('users').where('uid', isEqualTo: uid).get();

  final doctorServices = <DoctorService>[];

  for (final doc in selectedDoctorDocs.docs) {
    final docRef = await _firestore
        .collection('users')
        .doc(doc.id)
        .collection('service')
        .get();

    final listOfStudys = docRef.docs.map((serviceDoc) {
      if (serviceDoc.exists) {
        final serviceDocData = serviceDoc.data();
        final doctorService = DoctorService.fromJson(serviceDocData);
        return doctorService;
      } else {
        return null;
      }
    }).whereType<DoctorService>();

    doctorServices.addAll(listOfStudys);
  }

  return doctorServices;
}
