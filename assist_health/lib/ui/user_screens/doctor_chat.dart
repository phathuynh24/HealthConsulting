// ignore_for_file: avoid_print

import 'dart:async';

import 'package:assist_health/models/doctor/doctor_info.dart';
import 'package:assist_health/models/user/user_profile.dart';
import 'package:assist_health/others/methods.dart';
import 'package:assist_health/others/theme.dart';
import 'package:assist_health/ui/user_screens/chatroom_new.dart';
import 'package:assist_health/ui/user_screens/doctor_detail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class DoctorChatScreen extends StatefulWidget {
  const DoctorChatScreen({super.key});

  @override
  State<DoctorChatScreen> createState() => _DoctorChatState();
}

class _DoctorChatState extends State<DoctorChatScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  UserProfile? _userProfile;
  String? _uid;
  String? _idDoc;

  final StreamController<List<DoctorInfo>> _doctorStreamController =
      StreamController<List<DoctorInfo>>.broadcast();

  @override
  void initState() {
    super.initState();
    _uid = _auth.currentUser!.uid;
    _idDoc = 'main_profile';
    _doctorStreamController.addStream(getInfoDoctors());
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Themes.backgroundClr,
      appBar: AppBar(
        foregroundColor: Colors.white,
        toolbarHeight: 50,
        centerTitle: true,
        title: const Text('Chat với bác sĩ'),
        titleTextStyle: const TextStyle(fontSize: 16),
        elevation: 0,
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
      body: StreamBuilder<List<DoctorInfo>>(
        stream: _doctorStreamController.stream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Đã xảy ra lỗi: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          List<DoctorInfo> filterDoctorWithStatus;

          filterDoctorWithStatus = snapshot.data!;

          // filterDoctorWithStatus = snapshot.data!
          //     .where((doctor) => doctor.status == '')
          //     .toList();

          //---------------------------------------------------------

          // Xử lý lọc tìm kiếm tên bác sĩ
          List<DoctorInfo> filterDoctorWithName;
          // if (_searchName!.trim() != '') {
          //   filterDoctorWithName = filterDoctorWithStatus
          //       .where((doctor) => doctor.name
          //           .toLowerCase()
          //           .contains(_searchName!.toLowerCase()))
          //       .toList();
          // } else {
          filterDoctorWithName = filterDoctorWithStatus;
          //}
          //---------------------------------------------------------

          // Xử lý kh không tìm ra kết quả
          if (filterDoctorWithName.isEmpty) {
            return SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                height: 350,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Image.asset(
                      'assets/no_result_search_icon.png',
                      width: 250,
                      height: 250,
                      fit: BoxFit.contain,
                    ),
                    const Text(
                      'Không tìm thấy kết quả',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Text(
                      'Rất tiếc, chúng tôi không tìm thấy kết quả mà bạn mong muốn, hãy thử lại xem sao.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
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
              itemCount: filterDoctorWithName.length,
              itemBuilder: (context, index) {
                DoctorInfo doctor = filterDoctorWithName[index];

                return Container(
                  height: 185,
                  margin:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                  padding: const EdgeInsets.only(
                    top: 10,
                    left: 10,
                    right: 10,
                    bottom: 5,
                  ),
                  decoration: const BoxDecoration(color: Colors.white),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                                  margin: const EdgeInsets.only(
                                    right: 10,
                                  ),
                                  width: 90,
                                  height: 90,
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
                                                  size: 80,
                                                  color: Colors.white,
                                                ),
                                              );
                                            })
                                          : Center(
                                              child: Text(
                                                getAbbreviatedName(doctor.name),
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 30,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 255,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        doctor.careerTitiles,
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 14,
                                          height: 1.5,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Text(
                                        doctor.name,
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 14,
                                          height: 1.5,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Text(
                                        '${DateTime.now().year - doctor.graduationYear} năm kinh nghiệm',
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 14,
                                          height: 1.5,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          const Text(
                                            'Chuyên khoa: ',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 14,
                                              height: 1.5,
                                            ),
                                          ),
                                          SizedBox(
                                              height: 28,
                                              width: 155,
                                              child: ListView.builder(
                                                shrinkWrap: true,
                                                scrollDirection:
                                                    Axis.horizontal,
                                                itemCount:
                                                    doctor.specialty.length,
                                                itemBuilder: (context, index) {
                                                  final specialty =
                                                      doctor.specialty[index];
                                                  return Container(
                                                    margin: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 2),
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 9),
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20),
                                                      color: Colors.blueGrey
                                                          .withOpacity(0.1),
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                        specialty,
                                                        style: const TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 13,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w400),
                                                      ),
                                                    ),
                                                  );
                                                },
                                              )),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Divider(
                        thickness: 0.5,
                        color: Colors.grey.shade300,
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Expanded(
                            child: Container(
                              height: 50,
                              margin: const EdgeInsets.only(
                                left: 5,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  const Text(
                                    'Phí nhắn tin',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  Text(
                                    'Miễn phí',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.green.shade400,
                                      letterSpacing: 0.8,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                _showProfileListBottomSheet(context, doctor);
                              },
                              child: Container(
                                height: 50,
                                margin: const EdgeInsets.only(
                                  left: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: Themes.gradientDeepClr,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Center(
                                  child: Text(
                                    'Chat ngay',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Stream<List<DocumentSnapshot>> getUserProfilesStream() {
    return _firestore
        .collection('users')
        .doc(_uid!)
        .collection('health_profiles')
        .snapshots()
        .map((snapshot) => snapshot.docs);
  }

  void _showProfileListBottomSheet(BuildContext context, DoctorInfo doctor) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        UserProfile selectedUserProfile;
        if (_userProfile != null) {
          selectedUserProfile = _userProfile!;
        }

        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return StreamBuilder<List<DocumentSnapshot>>(
            stream: getUserProfilesStream(),
            builder: (BuildContext context,
                AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
              if (snapshot.hasData && snapshot.data != null) {
                final profiles = snapshot.data!.reversed.toList();
                _userProfile ??= UserProfile.fromJson(
                    profiles[0].data() as Map<String, dynamic>);
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      height: 5,
                      width: 50,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2.5),
                        color: Colors.grey.shade300,
                      ),
                    ),
                    Container(
                      height: 585,
                      padding: const EdgeInsets.symmetric(
                        vertical: 15,
                      ),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: Stack(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text(
                                'Tư vấn cho bệnh nhân',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              SizedBox(
                                height: 445,
                                child: ListView.builder(
                                  itemCount: profiles.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    final profile = profiles[index];
                                    UserProfile userProfile =
                                        UserProfile.fromJson(profile.data()
                                            as Map<String, dynamic>);
                                    bool isAvtEmpty = userProfile.image == '';
                                    bool isSelectedProfile =
                                        _userProfile!.idProfile ==
                                            userProfile.idProfile;
                                    return GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          selectedUserProfile = userProfile;
                                        });
                                        _updateSelectedProfile(userProfile);
                                      },
                                      child: Container(
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 15,
                                          vertical: 5,
                                        ),
                                        padding: const EdgeInsets.only(
                                          top: 10,
                                          left: 10,
                                          bottom: 10,
                                          right: 0,
                                        ),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: isSelectedProfile
                                                ? Themes.gradientDeepClr
                                                : Colors.grey.withOpacity(0.6),
                                            width:
                                                isSelectedProfile ? 1.5 : 0.5,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                GestureDetector(
                                                  onTap: () {
                                                    _showDetailProfileBottomSheet(
                                                        context, _userProfile!);
                                                  },
                                                  child: Container(
                                                    width: 90,
                                                    padding:
                                                        const EdgeInsets.all(4),
                                                    decoration: BoxDecoration(
                                                      color: Colors.blueAccent
                                                          .withOpacity(0.2),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                        'Xem chi tiết',
                                                        style: TextStyle(
                                                            color: Colors
                                                                .blue.shade900,
                                                            fontSize: 12),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const Spacer(),
                                                (isSelectedProfile)
                                                    ? Container(
                                                        margin: const EdgeInsets
                                                            .only(right: 10),
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 4,
                                                                horizontal: 8),
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(15),
                                                          color: Themes
                                                              .gradientDeepClr,
                                                          boxShadow: [
                                                            BoxShadow(
                                                              color: Colors.grey
                                                                  .withOpacity(
                                                                      0.5),
                                                              spreadRadius: 2,
                                                              blurRadius: 5,
                                                              offset:
                                                                  const Offset(
                                                                      0, 2),
                                                            ),
                                                          ],
                                                        ),
                                                        child: const Center(
                                                            child: Text(
                                                          'ĐANG CHỌN',
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 13,
                                                          ),
                                                        )),
                                                      )
                                                    : const SizedBox.shrink(),
                                              ],
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            Row(
                                              children: [
                                                Container(
                                                  margin: const EdgeInsets.only(
                                                    right: 10,
                                                  ),
                                                  child: Column(
                                                    children: [
                                                      Stack(
                                                        children: [
                                                          SizedBox(
                                                            width: 90,
                                                            child: Column(
                                                              children: [
                                                                SizedBox(
                                                                  width: 60,
                                                                  height: 60,
                                                                  child:
                                                                      ClipOval(
                                                                    child:
                                                                        Container(
                                                                      decoration:
                                                                          const BoxDecoration(
                                                                        gradient:
                                                                            LinearGradient(
                                                                          colors: [
                                                                            Themes.gradientDeepClr,
                                                                            Themes.gradientLightClr
                                                                          ],
                                                                          begin:
                                                                              Alignment.bottomCenter,
                                                                          end: Alignment
                                                                              .topCenter,
                                                                        ),
                                                                      ),
                                                                      child: (isAvtEmpty)
                                                                          ? Center(
                                                                              child: Text(
                                                                                getAbbreviatedName(userProfile.name),
                                                                                style: const TextStyle(
                                                                                  color: Colors.white,
                                                                                  fontSize: 25,
                                                                                  fontWeight: FontWeight.bold,
                                                                                ),
                                                                              ),
                                                                            )
                                                                          : Image.network(userProfile.image, fit: BoxFit.cover, errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                                                                              return const Center(
                                                                                child: Icon(
                                                                                  CupertinoIcons.person_circle_fill,
                                                                                  size: 50,
                                                                                  color: Colors.white,
                                                                                ),
                                                                              );
                                                                            }),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          Positioned(
                                                            top: 0,
                                                            right: 0,
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Container(
                                                                  padding: const EdgeInsets
                                                                      .symmetric(
                                                                      vertical:
                                                                          2,
                                                                      horizontal:
                                                                          4),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                          borderRadius: BorderRadius.circular(
                                                                              15),
                                                                          color: Themes.gradientDeepClr.withOpacity(
                                                                              0.9),
                                                                          border:
                                                                              Border.all(
                                                                            color:
                                                                                Colors.white,
                                                                            width:
                                                                                3,
                                                                          )),
                                                                  child: Center(
                                                                      child:
                                                                          Text(
                                                                    userProfile
                                                                        .relationship,
                                                                    style: const TextStyle(
                                                                        color: Colors
                                                                            .white,
                                                                        fontSize:
                                                                            12),
                                                                  )),
                                                                ),
                                                              ],
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 260,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        userProfile.name,
                                                        style: const TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 14,
                                                          height: 1.5,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                      Text(
                                                        'Ngày sinh: ${userProfile.doB}',
                                                        style: const TextStyle(
                                                          color: Colors.black87,
                                                          fontSize: 14,
                                                          height: 1.4,
                                                        ),
                                                      ),
                                                      Text(
                                                        'Số điện thoại: ${userProfile.phone}',
                                                        style: const TextStyle(
                                                          color: Colors.black,
                                                          fontSize: 14,
                                                          height: 1.5,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.only(
                                  top: 15,
                                ),
                                decoration: const BoxDecoration(
                                    border: Border(
                                        top: BorderSide(
                                  color: Colors.blueGrey,
                                  width: 0.3,
                                ))),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Container(
                                          width: double.infinity,
                                          height: 50,
                                          margin: const EdgeInsets.only(
                                            left: 20,
                                            right: 10,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.withOpacity(0.2),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: const Center(
                                            child: Text(
                                              'Đóng',
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.of(context).pop();
                                          goToChatRoom(doctor);
                                        },
                                        child: Container(
                                          width: double.infinity,
                                          height: 50,
                                          margin: const EdgeInsets.only(
                                            left: 10,
                                            right: 20,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Themes.gradientDeepClr,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: const Center(
                                            child: Text(
                                              'Tiếp tục',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Positioned(
                            top: 0,
                            right: 15,
                            child: GestureDetector(
                              onTap: () {
                                Navigator.of(context).pop();
                              },
                              child: const Icon(
                                Icons.close,
                                size: 24,
                                color: Colors.grey,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                );
              } else if (snapshot.hasError) {
                return Text('Đã xảy ra lỗi: ${snapshot.error}');
              } else {
                return const Text('Đang tải dữ liệu...');
              }
            },
          );
        });
      },
    );
  }

  void goToChatRoom(DoctorInfo doctor) async {
    try {
      var querySnapshot = await FirebaseFirestore.instance
          .collection('chatroom')
          .where('idProfile', isEqualTo: _userProfile!.idDoc)
          .where('idDoctor', isEqualTo: doctor.uid)
          .where('idUser', isEqualTo: _uid)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Tài liệu đã tồn tại, lấy ID của tài liệu đầu tiên
        String chatRoomId = querySnapshot.docs[0].id;

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ChatRoomNew(
              chatRoomId: chatRoomId,
              userProfile: _userProfile!,
              doctorInfo: doctor,
            ),
          ),
        );
      } else {
        // Tài liệu không tồn tại, tạo tài liệu mới
        var docRef =
            await FirebaseFirestore.instance.collection('chatroom').add({
          'idProfile': _userProfile!.idDoc,
          'idDoctor': doctor.uid,
          'idUser': _uid,
        });

        String chatRoomId = docRef.id;

        await docRef.update({'idDoc': chatRoomId});

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ChatRoomNew(
              chatRoomId: chatRoomId,
              userProfile: _userProfile!,
              doctorInfo: doctor,
            ),
          ),
        );
      }

      print('Chatroom created successfully');
    } catch (e) {
      print('Error creating or accessing chatroom: $e');
    }
  }

  _updateSelectedProfile(UserProfile selectedProfile) {
    setState(() {
      _userProfile = selectedProfile;
      _idDoc = selectedProfile.idDoc;
    });
  }

  void _showDetailProfileBottomSheet(
      BuildContext context, UserProfile userProfile) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return Container(
            color: Colors.transparent,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  height: 5,
                  width: 50,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2.5),
                    color: Colors.grey.shade300,
                  ),
                ),
                Container(
                  height: 600,
                  padding: const EdgeInsets.symmetric(
                    vertical: 15,
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Stack(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            'Chi tiết hồ sơ',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.9,
                            margin: const EdgeInsets.all(20),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.grey.shade300,
                                  width: 1,
                                )),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(
                                  height: 5,
                                ),
                                Row(
                                  children: [
                                    const Text(
                                      'Mã bệnh nhân:',
                                      style: TextStyle(
                                        color: Colors.black87,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      userProfile.idProfile,
                                      style: const TextStyle(
                                          color: Colors.black87,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                Row(
                                  children: [
                                    const Text(
                                      'Họ và tên:',
                                      style: TextStyle(
                                        color: Colors.black87,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      userProfile.name,
                                      style: const TextStyle(
                                          color: Colors.black87,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                Row(
                                  children: [
                                    const Text(
                                      'Giới tính:',
                                      style: TextStyle(
                                        color: Colors.black87,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      userProfile.gender,
                                      style: const TextStyle(
                                          color: Colors.black87,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                Row(
                                  children: [
                                    const Text(
                                      'Ngày sinh:',
                                      style: TextStyle(
                                        color: Colors.black87,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      userProfile.doB,
                                      style: const TextStyle(
                                          color: Colors.black87,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                Row(
                                  children: [
                                    const Text(
                                      'Điện thoại:',
                                      style: TextStyle(
                                        color: Colors.black87,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      userProfile.phone,
                                      style: const TextStyle(
                                        color: Colors.black87,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: 1.1,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                const Row(
                                  children: [
                                    Text(
                                      'Mã bảo hiểm y tế',
                                      style: TextStyle(
                                        color: Colors.black87,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Spacer(),
                                    Text(
                                      'Chưa cập nhật',
                                      style: TextStyle(
                                          color: Colors.black45,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                const Row(
                                  children: [
                                    Text(
                                      'Địa chỉ',
                                      style: TextStyle(
                                        color: Colors.black87,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Spacer(),
                                    Text(
                                      'Chưa cập nhật',
                                      style: TextStyle(
                                          color: Colors.black45,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                const Row(
                                  children: [
                                    Text(
                                      'Dân tộc',
                                      style: TextStyle(
                                        color: Colors.black87,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Spacer(),
                                    Text(
                                      'Chưa cập nhật',
                                      style: TextStyle(
                                          color: Colors.black45,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                const Row(
                                  children: [
                                    Text(
                                      'Nghề nghiệp',
                                      style: TextStyle(
                                        color: Colors.black87,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Spacer(),
                                    Text(
                                      'Chưa cập nhật',
                                      style: TextStyle(
                                          color: Colors.black45,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                const Row(
                                  children: [
                                    Text(
                                      'Email',
                                      style: TextStyle(
                                        color: Colors.black87,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Spacer(),
                                    Text(
                                      'Chưa cập nhật',
                                      style: TextStyle(
                                          color: Colors.black45,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Container(
                                    width: double.infinity,
                                    height: 50,
                                    margin: const EdgeInsets.only(
                                      left: 20,
                                      right: 20,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Center(
                                      child: Text(
                                        'Đóng',
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Positioned(
                        top: 0,
                        right: 15,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: const Icon(
                            Icons.close,
                            size: 24,
                            color: Colors.grey,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          );
        });
      },
    );
  }
}
