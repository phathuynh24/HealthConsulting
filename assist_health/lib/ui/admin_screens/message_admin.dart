import 'package:assist_health/others/theme.dart';
import 'package:assist_health/ui/user_screens/chatroom.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MessageAdminScreen extends StatefulWidget {
  const MessageAdminScreen({Key? key}) : super(key: key);

  @override
  State<MessageAdminScreen> createState() => _MessageAdminScreenState();
}

class _MessageAdminScreenState extends State<MessageAdminScreen>
    with WidgetsBindingObserver {
  List<Map<String, dynamic>> userList = [];
  List<Map<String, dynamic>> doctorList = [];
  bool isLoading = false;
  bool showDoctors = false; // Switch button state
  Map<String, dynamic>? userMap;
  final TextEditingController _search = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        setStatus("online");
      } else {
        setStatus("offline");
      }
    });
    onLoadUsers();
    onLoadDoctors();
  }

  void setStatus(String status) async {
    if (_auth.currentUser != null) {
      await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .update({"status": status});
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (_auth.currentUser != null) {
        setStatus("online");
      }
    } else {
      if (_auth.currentUser != null) {
        setStatus("offline");
      }
    }
  }

  String chatRoomId(String user1, String user2) {
    return user1[0].toLowerCase().codeUnits[0] >
            user2[0].toLowerCase().codeUnits[0]
        ? "$user1$user2"
        : "$user2$user1";
  }

  void onSearch() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    setState(() {
      isLoading = true;
      doctorList = [];
      userList = [];
    });

    String searchText = _search.text.trim().toLowerCase();
    if (searchText.isEmpty) {
      setState(() {
        if (showDoctors) {
          onLoadDoctors();
        } else {
          onLoadUsers();
        }
        isLoading = false;
      });
      return;
    }

    await firestore
        .collection('users')
        .where("role", isEqualTo: showDoctors ? "doctor" : "user")
        .get()
        .then((value) {
      setState(() {
        if (showDoctors) {
          doctorList = value.docs
              .where((doc) => doc['name'].toLowerCase().contains(searchText))
              .map((doc) => doc.data())
              .toList();
        } else {
          userList = value.docs
              .where((doc) => doc['name'].toLowerCase().contains(searchText))
              .map((doc) => doc.data())
              .toList();
        }
        isLoading = false;
      });
    });
  }

  void onLoadUsers() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    setState(() {
      isLoading = true;
    });

    await firestore
        .collection('users')
        .where("role", isEqualTo: "user")
        .get()
        .then((value) {
      if (value.docs.isNotEmpty) {
        setState(() {
          userList = value.docs.map((doc) => doc.data()).toList();
          isLoading = false;
        });
      } else {
        setState(() {
          userList = [];
          isLoading = false;
        });
      }
    });
  }

  void onLoadDoctors() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    setState(() {
      isLoading = true;
    });

    await firestore
        .collection('users')
        .where("role", isEqualTo: "doctor")
        .get()
        .then((value) {
      if (value.docs.isNotEmpty) {
        setState(() {
          doctorList = value.docs.map((doc) => doc.data()).toList();
          isLoading = false;
        });
      } else {
        setState(() {
          doctorList = [];
          isLoading = false;
        });
      }
    });
  }

  Color getStatusDotColor(bool isOnline) {
    return isOnline ? Colors.green : Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hỏi đáp riêng cùng bác sĩ'),
        centerTitle: true,
        automaticallyImplyLeading: false,
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
          ? SingleChildScrollView(
              child: Center(
                child: SizedBox(
                  height: size.height / 20,
                  width: size.height / 20,
                  child: const CircularProgressIndicator(),
                ),
              ),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: size.height / 40,
                  ),
                  Container(
                    height: size.height / 14,
                    width: size.width,
                    alignment: Alignment.center,
                    child: SizedBox(
                      height: size.height / 14,
                      width: size.width / 1.15,
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _search,
                              onChanged: (value) {
                                onSearch();
                              },
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.search),
                                hintText: "Tìm kiếm...",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          Switch(
                            value: showDoctors,
                            onChanged: (value) {
                              setState(() {
                                showDoctors = value;
                                onSearch();
                              });
                            },
                          ),
                          Text(showDoctors ? 'Bác sĩ' : 'Người dùng'),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: size.height / 60,
                  ),
                  if (showDoctors)
                    if (doctorList.isNotEmpty)
                      Container(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: doctorList.length,
                          itemBuilder: (context, index) {
                            Map<String, dynamic> doctor = doctorList[index];
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 5,
                              ),
                              child: ListTile(
                                onTap: () {
                                  String roomId = chatRoomId(
                                    _auth.currentUser!.displayName!,
                                    doctor['name'],
                                  );
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => ChatRoom(
                                        chatRoomId: roomId,
                                        userMap: doctor,
                                      ),
                                    ),
                                  );
                                },
                                leading: Stack(
                                  children: [
                                    CircleAvatar(
                                      radius: 30,
                                      backgroundImage: NetworkImage(
                                        doctor['imageURL'],
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: Container(
                                        height: 12,
                                        width: 12,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: getStatusDotColor(
                                            doctor['status'] == 'online',
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                title: Text(
                                  doctor['name'],
                                  style: const TextStyle(
                                    color: Colors.black,
                                    height: 1.5,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                trailing:
                                    const Icon(Icons.chat, color: Colors.black),
                              ),
                            );
                          },
                        ),
                      ),
                  if (!showDoctors)
                    if (userList.isNotEmpty)
                      Container(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: userList.length,
                          itemBuilder: (context, index) {
                            Map<String, dynamic> user = userList[index];
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 5,
                              ),
                              child: ListTile(
                                onTap: () {
                                  String roomId = chatRoomId(
                                    _auth.currentUser!.displayName!,
                                    user['name'],
                                  );
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => ChatRoom(
                                        chatRoomId: roomId,
                                        userMap: user,
                                      ),
                                    ),
                                  );
                                },
                                leading: CircleAvatar(
                                  radius: 30,
                                  backgroundImage: NetworkImage(
                                    user['imageURL'],
                                  ),
                                ),
                                title: Text(
                                  user['name'],
                                  style: const TextStyle(
                                    color: Colors.black,
                                    height: 1.5,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                trailing:
                                    const Icon(Icons.chat, color: Colors.black),
                              ),
                            );
                          },
                        ),
                      ),
                ],
              ),
            ),
    );
  }
}
