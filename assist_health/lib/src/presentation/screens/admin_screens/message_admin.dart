// ignore_for_file: avoid_print

import 'package:assist_health/src/models/doctor/doctor_info.dart';
import 'package:assist_health/src/models/other/chat.dart';
import 'package:assist_health/src/others/theme.dart';
import 'package:assist_health/src/presentation/screens/user_screens/chatroom.dart';
import 'package:assist_health/src/widgets/doctor_navbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MessageAdminScreen extends StatefulWidget {
  const MessageAdminScreen({super.key});

  @override
  State<MessageAdminScreen> createState() => _MessageAdminScreenState();
}

class _MessageAdminScreenState extends State<MessageAdminScreen> {
  List<Chat> chatRoomList = [];
  List<Chat> tempChatRoomList = [];
  List<DoctorInfo> doctorList = [];
  List<Map<String, dynamic>> userProfiles = [];
  List<Map<String, dynamic>> adminList = [];
  bool isLoading = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';

  bool showDoctorMassage = false;

  @override
  void initState() {
    super.initState();
    getChatRoom();
    tempChatRoomList = chatRoomList;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void getChatRoom() async {
    setState(() {
      isLoading = true;
    });

    // Lấy danh sách bác sĩ
    await getDoctors();

    // Lấy danh sách admin
    await getAdmins();

    // Lấy danh sách chatroom của bác sĩ này
    List<Chat> tempChatRoomList = [];
    await _firestore
        .collection('chatroom')
        .where('idDoctor', isEqualTo: _auth.currentUser!.uid)
        .get()
        .then((value) {
      if (value.docs.isNotEmpty) {
        tempChatRoomList =
            value.docs.map((doc) => Chat.fromJson(doc.data())).toList();
        setState(() {
          chatRoomList = tempChatRoomList
              .where((element) => element.idDoctor == _auth.currentUser!.uid)
              .toList();
        });
      }
    });
    // Lấy danh sách hồ sơ sức khỏe đã chat với bác sĩ này
    await getUserProfiles();

    setState(() {
      isLoading = false;
    });
  }

  Future<void> getUserProfiles() async {
    List<Map<String, dynamic>> tempUserProfiles = [];
    try {
      final userQuerySnapshot = await _firestore
          .collection('users')
          .where("role", whereIn: ["user"]).get();

      if (userQuerySnapshot.docs.isNotEmpty) {
        tempUserProfiles =
            userQuerySnapshot.docs.map((doc) => doc.data()).toList();
        setState(() {
          userProfiles = tempUserProfiles
              .where((element1) => chatRoomList
                  .any((element2) => element2.idProfile == element1['uid']))
              .toList();
        });
      } else {
        setState(() {
          userProfiles = [];
        });
      }
    } catch (error) {
      print("Lỗi khi truy xuất dữ liệu: $error");
    }
  }

  Future<void> getDoctors() async {
    try {
      // Lấy danh sách bác sĩ
      final userDocs = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'doctor')
          .get();
      if (userDocs.docs.isNotEmpty) {
        setState(() {
          doctorList = userDocs.docs
              .map((doc) => DoctorInfo.fromJson(doc.data()))
              .toList();
        });
      } else {
        setState(() {
          doctorList = [];
        });
      }
    } catch (error) {
      // Xử lý lỗi nếu có
      print('Lỗi khi lấy danh sách bác sĩ: $error');
    }
  }

  getAdmins() async {
    // Lấy danh sách admin
    await _firestore
        .collection('users')
        .where("role", whereIn: ["admin"])
        .get()
        .then((value) {
          if (value.docs.isNotEmpty) {
            setState(() {
              adminList = value.docs
                  .where((doc) => doc['role'] == 'admin')
                  .map((doc) => doc.data())
                  .toList();
            });
          } else {
            setState(() {
              adminList = [];
            });
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const DoctorNavBar()),
          (route) => false,
        );
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          foregroundColor: Colors.white,
          toolbarHeight: 80,
          title: Column(
            children: [
              const Text(
                'Tin nhắn',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.9),
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.blueGrey.shade800.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: TextFormField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(10),
                    hintText: 'Tên bác sĩ, bệnh nhân...',
                    hintStyle: const TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Colors.white70,
                      size: 23,
                    ),
                    border: InputBorder.none,
                    suffixIconConstraints:
                        const BoxConstraints(maxHeight: 30, maxWidth: 30),
                    suffixIcon: GestureDetector(
                      onTap: () {
                        setState(() {
                          _searchText = '';
                          _searchController.text = _searchText;
                        });
                      },
                      child: Container(
                        width: 16,
                        height: 16,
                        margin: const EdgeInsets.only(
                          right: 10,
                        ),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white70,
                        ),
                        child: Center(
                          child: Icon(
                            Icons.clear,
                            size: 15,
                            color: Colors.blueGrey.shade700,
                          ),
                        ),
                      ),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchText = value;
                      _searchController.text = _searchText;
                    });
                  },
                ),
              ),
            ],
          ),
          centerTitle: true,
          automaticallyImplyLeading: false,
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
        body: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 5, horizontal: 15),
                      decoration: BoxDecoration(
                          border: Border(
                        bottom: BorderSide(color: Colors.blueGrey.shade100),
                      )),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  showDoctorMassage = false;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: !showDoctorMassage
                                      ? Themes.gradientDeepClr
                                      : Colors.white,
                                ),
                                child: Center(
                                  child: Text(
                                    'Bệnh nhân',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: !showDoctorMassage
                                          ? Colors.white
                                          : Colors.grey.shade600,
                                      fontWeight: !showDoctorMassage
                                          ? FontWeight.w500
                                          : FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  showDoctorMassage = true;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: showDoctorMassage
                                      ? Themes.gradientDeepClr
                                      : Colors.white,
                                ),
                                child: Center(
                                  child: Text(
                                    'Bác sĩ',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: showDoctorMassage
                                          ? Colors.white
                                          : Colors.grey.shade600,
                                      fontWeight: showDoctorMassage
                                          ? FontWeight.w500
                                          : FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    // Display list
                    if (chatRoomList.isNotEmpty)
                      if (showDoctorMassage)
                        SingleChildScrollView(
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: chatRoomList.length,
                            itemBuilder: (context, index) {
                              Chat chatRoom = chatRoomList[index];
                              List<Chat> tempChatRoomList = chatRoomList;
                              List<DoctorInfo> tempDoctorList = [];
                              for (var element1 in doctorList) {
                                if (tempChatRoomList.any((element2) =>
                                    element2.idUser == element1.uid)) {
                                  tempDoctorList.add(element1);
                                }
                              }

                              DoctorInfo doctor;
                              try {
                                doctor = tempDoctorList.firstWhere(
                                  (element) => element.uid == chatRoom.idUser,
                                );
                                return Column(
                                  children: [
                                    ListTile(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 8),
                                      onTap: () {
                                        goToChatRoomDoctor(doctor);
                                      },
                                      leading: CircleAvatar(
                                        radius: 30,
                                        backgroundImage: NetworkImage(
                                          doctor.imageURL,
                                        ),
                                      ),
                                      title: Text(
                                        'Bác sĩ ${doctor.name}',
                                        style: const TextStyle(
                                          color: Colors.black,
                                          height: 1.5,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    Divider(
                                      color: Colors.grey.shade400,
                                      thickness: 0.5,
                                      height: 20,
                                    ),
                                  ],
                                );
                              } catch (e) {}
                              return null;

                              // List<Map<String, dynamic>> tempUserProfileList = [];
                              // if (_searchText == '') {
                              //   tempUserProfileList = userProfiles;
                              //   print(userProfiles.length + 100);
                              // } else {
                              //   String searchText =
                              //       _searchText.trim().toLowerCase();
                              //   tempUserProfileList = userProfiles
                              //       .where((element) => element['name']
                              //           .toLowerCase()
                              //           .contains(searchText))
                              //       .toList();
                              // }

                              // // Xử lý không tìm ra kết quả
                              // if (tempUserProfileList.isEmpty && index == 0) {
                              //   return SingleChildScrollView(
                              //     child: Container(
                              //       margin: const EdgeInsets.symmetric(
                              //           horizontal: 20),
                              //       height: 350,
                              //       child: Column(
                              //         mainAxisAlignment:
                              //             MainAxisAlignment.spaceEvenly,
                              //         children: [
                              //           Image.asset(
                              //             'assets/no_result_search_icon.png',
                              //             width: 250,
                              //             height: 250,
                              //             fit: BoxFit.contain,
                              //           ),
                              //           const Text(
                              //             'Không tìm thấy kết quả',
                              //             style: TextStyle(
                              //               fontWeight: FontWeight.bold,
                              //               fontSize: 15,
                              //             ),
                              //           ),
                              //           const SizedBox(
                              //             height: 10,
                              //           ),
                              //           const Text(
                              //             'Rất tiếc, chúng tôi không tìm thấy kết quả mà bạn mong muốn, hãy thử lại xem sao.',
                              //             textAlign: TextAlign.center,
                              //             style: TextStyle(
                              //               fontSize: 14,
                              //               color: Colors.grey,
                              //               height: 1.5,
                              //             ),
                              //           ),
                              //         ],
                              //       ),
                              //     ),
                              //   );
                              // }
                              // //--------------------------------
                            },
                          ),
                        )
                      else
                        SingleChildScrollView(
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: 1,
                            itemBuilder: (context, index) {
                              print('====0000');
                              print(index);
                              print(chatRoomList.length);
                              print(chatRoomList[index].idDoctor);
                              print(chatRoomList[index].idUser);
                              Chat chatRoom = chatRoomList[1];

                              Map<String, dynamic> user;
                              try {
                                user = userProfiles.firstWhere(
                                  (element) =>
                                      element['uid'] == chatRoom.idUser,
                                );

                                return Column(
                                  children: [
                                    ListTile(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 8),
                                      onTap: () {
                                        goToChatRoomUser(user['uid']);
                                      },
                                      leading: CircleAvatar(
                                        radius: 30,
                                        backgroundImage: NetworkImage(
                                          user['imageURL'],
                                        ),
                                      ),
                                      title: Text(
                                        'Bệnh nhân ${user['name']}',
                                        style: const TextStyle(
                                          color: Colors.black,
                                          height: 1.5,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    Divider(
                                      color: Colors.grey.shade400,
                                      thickness: 0.5,
                                      height: 20,
                                    ),
                                  ],
                                );
                              } catch (e) {}
                              return null;

                              // List<Map<String, dynamic>> tempUserProfileList = [];
                              // if (_searchText == '') {
                              //   tempUserProfileList = userProfiles;
                              //   print(userProfiles.length + 100);
                              // } else {
                              //   String searchText =
                              //       _searchText.trim().toLowerCase();
                              //   tempUserProfileList = userProfiles
                              //       .where((element) => element['name']
                              //           .toLowerCase()
                              //           .contains(searchText))
                              //       .toList();
                              // }

                              // // Xử lý không tìm ra kết quả
                              // if (tempUserProfileList.isEmpty && index == 0) {
                              //   return SingleChildScrollView(
                              //     child: Container(
                              //       margin: const EdgeInsets.symmetric(
                              //           horizontal: 20),
                              //       height: 350,
                              //       child: Column(
                              //         mainAxisAlignment:
                              //             MainAxisAlignment.spaceEvenly,
                              //         children: [
                              //           Image.asset(
                              //             'assets/no_result_search_icon.png',
                              //             width: 250,
                              //             height: 250,
                              //             fit: BoxFit.contain,
                              //           ),
                              //           const Text(
                              //             'Không tìm thấy kết quả',
                              //             style: TextStyle(
                              //               fontWeight: FontWeight.bold,
                              //               fontSize: 15,
                              //             ),
                              //           ),
                              //           const SizedBox(
                              //             height: 10,
                              //           ),
                              //           const Text(
                              //             'Rất tiếc, chúng tôi không tìm thấy kết quả mà bạn mong muốn, hãy thử lại xem sao.',
                              //             textAlign: TextAlign.center,
                              //             style: TextStyle(
                              //               fontSize: 14,
                              //               color: Colors.grey,
                              //               height: 1.5,
                              //             ),
                              //           ),
                              //         ],
                              //       ),
                              //     ),
                              //   );
                              // }
                              // //--------------------------------
                            },
                          ),
                        ),
                  ],
                ),
              ),
      ),
    );
  }

  void goToChatRoomUser(String id) async {
    try {
      var querySnapshot = await FirebaseFirestore.instance
          .collection('chatroom')
          .where('idProfile', isEqualTo: id)
          .where('idDoctor', isEqualTo: _auth.currentUser!.uid)
          .where('idUser', isEqualTo: id)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Tài liệu đã tồn tại, lấy ID của tài liệu đầu tiên
        String chatRoomId = querySnapshot.docs[0].id;

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ChatRoom(
              chatRoomId: chatRoomId,
              userMap: userProfiles[0],
              isUser: true,
            ),
          ),
        );
      }

      print('Chatroom created successfully');
    } catch (e) {
      print('Error creating or accessing chatroom: $e');
    }
  }

  void goToChatRoomDoctor(DoctorInfo doctor) async {
    try {
      var querySnapshot = await FirebaseFirestore.instance
          .collection('chatroom')
          .where('idProfile', isEqualTo: doctor.uid)
          .where('idDoctor', isEqualTo: _auth.currentUser!.uid)
          .where('idUser', isEqualTo: doctor.uid)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Tài liệu đã tồn tại, lấy ID của tài liệu đầu tiên
        String chatRoomId = querySnapshot.docs[0].id;

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ChatRoom(
              chatRoomId: chatRoomId,
              userMap: doctor.toMap(),
              isUser: false,
            ),
          ),
        );
      }

      print('Chatroom created successfully');
    } catch (e) {
      print('Error creating or accessing chatroom: $e');
    }
  }
}
