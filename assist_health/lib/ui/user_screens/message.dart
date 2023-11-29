import 'package:assist_health/others/methods.dart';
import 'package:assist_health/models/doctor/doctor_info.dart';
import 'package:assist_health/others/theme.dart';
import 'package:assist_health/ui/user_screens/chatroom.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MessageScreen extends StatefulWidget {
  const MessageScreen({super.key});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen>
    with WidgetsBindingObserver {
  List<Map<String, dynamic>> doctorList = [];
  bool isLoading = false;
  Map<String, dynamic>? userMap;
  final TextEditingController _search = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // setStatus("online");
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        // User is signed in, update status to "online"
        setStatus("online");
      } else {
        // User is signed out, update status to "offline"
        setStatus("offline");
      }
    });
    onLoadDoctors();
  }

  // void setStatus(String status) async {
  //   await _firestore.collection('users').doc(_auth.currentUser!.uid).update({
  //     "status": status,
  //   });
  // }
  void setStatus(String status) async {
    if (_auth.currentUser != null) {
      await _firestore.collection('users').doc(_auth.currentUser!.uid).update({
        "status": status,
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // App is in the foreground, user is online
      if (_auth.currentUser != null) {
        setStatus("online");
      }
    } else {
      // App is in the background, user is considered offline
      if (_auth.currentUser != null) {
        setStatus("offline");
      }
    }
  }

  String chatRoomId(String user1, String user2) {
    if (user1[0].toLowerCase().codeUnits[0] >
        user2[0].toLowerCase().codeUnits[0]) {
      return "$user1$user2";
    } else {
      return "$user2$user1";
    }
  }

  void onSearch() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    setState(() {
      isLoading = true;
    });
    String searchText = _search.text.trim();
    if (searchText.isEmpty) {
      setState(() {
        onLoadDoctors();
        isLoading = false;
      });
      return;
    }
    await firestore
        .collection('users')
        .where("email", isEqualTo: searchText)
        .get()
        .then((value) {
      setState(() {
        if (value.docs.isNotEmpty) {
          userMap = value.docs[0].data();
          doctorList = [userMap!];
        } else {
          userMap = null;
          doctorList = [];
        }
        isLoading = false;
      });
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

  //online offline
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
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Themes.leftClr, Themes.rightClr],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Implement search functionality
            },
          ),
        ],
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
                    height: size.height / 20,
                  ),
                  Container(
                    height: size.height / 14,
                    width: size.width,
                    alignment: Alignment.center,
                    child: SizedBox(
                      height: size.height / 14,
                      width: size.width / 1.15,
                      child: TextField(
                        controller: _search,
                        onSubmitted: (value) {
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
                  ),
                  SizedBox(
                    height: size.height / 50,
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Themes.buttonClr,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: onSearch,
                    child: const Text(
                      "Tìm kiếm",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  SizedBox(
                    height: size.height / 30,
                  ),
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
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: doctorList.length,
                          itemBuilder: (context, index) {
                            Map<String, dynamic> doctor = doctorList[index];
                            return Container(
                              padding: EdgeInsets.symmetric(
                                vertical: 5,
                              ),
                              child: ListTile(
                                onTap: () {
                                  String roomId = chatRoomId(
                                      _auth.currentUser!.displayName!,
                                      doctor['name']);
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
                                          snapshot.data![index].image),
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
                                              doctor['status'] == 'online'),
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
                                subtitle: Text(
                                  doctor['email'],
                                  style: const TextStyle(
                                    color: Colors.black54,
                                    height: 1.5,
                                  ),
                                ),
                                trailing:
                                    const Icon(Icons.chat, color: Colors.black),
                              ),
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
