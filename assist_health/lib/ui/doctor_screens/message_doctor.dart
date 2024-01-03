// ignore_for_file: avoid_print

import 'package:assist_health/models/doctor/doctor_info.dart';
import 'package:assist_health/models/other/chat.dart';
import 'package:assist_health/models/user/user_profile.dart';
import 'package:assist_health/others/theme.dart';
import 'package:assist_health/ui/user_screens/chatroom.dart';
import 'package:assist_health/ui/user_screens/chatroom_new.dart';
import 'package:assist_health/ui/widgets/user_navbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MessageDoctorScreen extends StatefulWidget {
  const MessageDoctorScreen({super.key});

  @override
  State<MessageDoctorScreen> createState() => _MessageDoctorScreenState();
}

class _MessageDoctorScreenState extends State<MessageDoctorScreen> {
  List<Chat> chatRoomList = [];
  List<DoctorInfo> doctorList = [];
  List<UserProfile> userProfiles = [];
  List<Map<String, dynamic>> adminList = [];
  bool isLoading = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    getChatRoom();
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
    List<UserProfile> tempUserProfiles = [];
    try {
      final userQuerySnapshot = await _firestore
          .collection('users')
          .where("role", whereIn: ["user"]).get();

      if (userQuerySnapshot.docs.isNotEmpty) {
        final userProfilesQuerySnapshot = await _firestore
            .collection('users')
            .doc(userQuerySnapshot.docs[0].id)
            .collection('health_profiles')
            .get();
        tempUserProfiles = userProfilesQuerySnapshot.docs
            .map((doc) => UserProfile.fromJson(doc.data()))
            .toList();
        setState(() {
          userProfiles = tempUserProfiles
              .where((element1) => chatRoomList
                  .any((element2) => element2.idProfile == element1.idDoc))
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
      final userDoc = await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .get();
      if (userDoc.exists) {
        setState(() {
          doctorList.add(DoctorInfo.fromJson(userDoc.data()!));
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
          MaterialPageRoute(builder: (context) => const UserNavBar()),
          (route) => false,
        );
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          foregroundColor: Colors.white,
          toolbarHeight: 60,
          title: Column(
            children: [
              const SizedBox(
                height: 10,
              ),
              Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.blueGrey.shade800.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextFormField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(10),
                    hintText: 'Tên bệnh nhân...',
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
        ),
        body: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(
                      height: 10,
                    ),

                    // Display admin
                    if (adminList.isNotEmpty)
                      Column(
                        children: [
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: adminList.length,
                            itemBuilder: (context, index) {
                              return Column(
                                children: [
                                  const Divider(
                                    color: Colors.grey,
                                    thickness: 1.0,
                                    height: 6,
                                  ),
                                  ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    onTap: () {
                                      goToChatRoom();
                                    },
                                    leading: const Stack(
                                      children: [
                                        CircleAvatar(
                                          radius: 30,
                                          backgroundImage: AssetImage(
                                              'assets/health_care_logo_nobg.png'),
                                        )
                                      ],
                                    ),
                                    title: const Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Chăm Sóc Khách Hàng',
                                          style: TextStyle(
                                            color: Colors.black,
                                            height: 1.5,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Text(
                                          'Thứ 2 -Thứ 7: 8h30 - 17h30',
                                          style: TextStyle(
                                            color: Colors.black,
                                            height: 1.2,
                                            fontSize: 14,
                                            fontWeight: FontWeight.normal,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (index < adminList.length - 1)
                                    const Divider(
                                      color: Colors.grey,
                                      thickness: 1.0,
                                    ),
                                ],
                              );
                            },
                          ),
                          Divider(
                            color: Colors.grey.shade400,
                            thickness: 0.5,
                          ),
                        ],
                      ),

                    // Display doctor list
                    if (chatRoomList.isNotEmpty)
                      SingleChildScrollView(
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: chatRoomList.length,
                          itemBuilder: (context, index) {
                            if (chatRoomList[index].idDoctor !=
                                chatRoomList[index].idUser) {
                              Chat chatRoom = chatRoomList[index];
                              bool isProfileExist = false;
                              DoctorInfo doctor = doctorList[0];
                              UserProfile userProfile = userProfiles.firstWhere(
                                (element) =>
                                    element.idDoc == chatRoom.idProfile,
                              );

                              List<UserProfile> tempUserProfileList = [];
                              if (_searchText == '') {
                                tempUserProfileList = userProfiles;
                              } else {
                                String searchText =
                                    _searchText.trim().toLowerCase();
                                tempUserProfileList = userProfiles
                                    .where((element) => element.name
                                        .toLowerCase()
                                        .contains(searchText))
                                    .toList();
                              }

                              // Xử lý không tìm ra kết quả
                              if (tempUserProfileList.isEmpty && index == 0) {
                                return SingleChildScrollView(
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 20),
                                    height: 350,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
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
                              //--------------------------------

                              try {
                                userProfile = tempUserProfileList.firstWhere(
                                  (element) =>
                                      element.idDoc ==
                                      chatRoomList[index].idProfile,
                                );
                                isProfileExist = true;
                              } catch (e) {
                                isProfileExist = false;
                              }

                              if (isProfileExist) {
                                userProfile = tempUserProfileList.firstWhere(
                                    (element) =>
                                        element.idDoc ==
                                        chatRoomList[index].idProfile);

                                return Column(
                                  children: [
                                    ListTile(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 8),
                                      onTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) => ChatRoomNew(
                                              chatRoomId:
                                                  chatRoomList[index].idDoc!,
                                              userProfile: userProfile,
                                              doctorInfo: doctor,
                                            ),
                                          ),
                                        );
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
                                      subtitle: Row(
                                        children: [
                                          const Icon(
                                            CupertinoIcons
                                                .arrow_turn_down_right,
                                            size: 20,
                                            color: Colors.blueGrey,
                                          ),
                                          const SizedBox(
                                            width: 8,
                                          ),
                                          Text(
                                            'Bệnh nhân ${userProfile.name}',
                                            style: const TextStyle(
                                              color: Colors.blueGrey,
                                              height: 1.5,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Divider(
                                      color: Colors.grey.shade400,
                                      thickness: 0.5,
                                      height: 20,
                                    ),
                                  ],
                                );
                              } else {
                                return const SizedBox();
                              }
                            }
                            return const SizedBox();
                          },
                        ),
                      ),
                  ],
                ),
              ),
      ),
    );
  }

  void goToChatRoom() async {
    try {
      Map<String, dynamic> admin = adminList[0];
      var querySnapshot = await FirebaseFirestore.instance
          .collection('chatroom')
          .where('idProfile', isEqualTo: _auth.currentUser!.uid)
          .where('idDoctor', isEqualTo: admin['uid'])
          .where('idUser', isEqualTo: _auth.currentUser!.uid)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Tài liệu đã tồn tại, lấy ID của tài liệu đầu tiên
        String chatRoomId = querySnapshot.docs[0].id;

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ChatRoom(
              chatRoomId: chatRoomId,
              userMap: adminList[0],
            ),
          ),
        );
      } else {
        // Tài liệu không tồn tại, tạo tài liệu mới
        var docRef =
            await FirebaseFirestore.instance.collection('chatroom').add({
          'idProfile': _auth.currentUser!.uid,
          'idDoctor': admin['uid'],
          'idUser': _auth.currentUser!.uid,
        });

        String chatRoomId = docRef.id;

        await docRef.update({'idDoc': chatRoomId});

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ChatRoom(
              chatRoomId: chatRoomId,
              userMap: adminList[0],
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
