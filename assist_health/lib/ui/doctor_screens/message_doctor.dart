import 'package:assist_health/others/theme.dart';
import 'package:assist_health/ui/user_screens/chatroom.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MessageDoctorScreen extends StatefulWidget {
  const MessageDoctorScreen({Key? key}) : super(key: key);

  @override
  State<MessageDoctorScreen> createState() => _MessageDoctorScreenState();
}

class _MessageDoctorScreenState extends State<MessageDoctorScreen> with WidgetsBindingObserver {
  List<Map<String, dynamic>> userList = [];
  bool isLoading = false;
  Map<String, dynamic>? userMap;
  final TextEditingController _search = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool showChattedUsers = false;
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
    return user1[0].toLowerCase().codeUnits[0] > user2[0].toLowerCase().codeUnits[0]
        ? "$user1$user2"
        : "$user2$user1";
  }
  void toggleChattedUsers() {
    setState(() {
      showChattedUsers = !showChattedUsers;
      if (showChattedUsers) {
        filterChattedUsers();
      } else {
        onLoadDoctors();
      }
    });
  }

  void filterChattedUsers() async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  setState(() {
    isLoading = true;
  });

  // Fetch the list of chat rooms for the current user
  QuerySnapshot chatRoomsSnapshot = await firestore
      .collection('chatroom')
      .where('users', arrayContains: _auth.currentUser!.uid)
      .get();

  // Extract doctor IDs from the chat rooms
  List<String> doctorIds = [];
  for (QueryDocumentSnapshot room in chatRoomsSnapshot.docs) {
    List<dynamic> users = room['users'];
    doctorIds.addAll(users.where((id) => id != _auth.currentUser!.uid).whereType<String>());
  }

  doctorIds = doctorIds.toSet().toList();

  if (doctorIds.isNotEmpty) {
    // Fetch the details of doctors based on the filtered IDs
    await firestore
        .collection('users')
        .where("role", isEqualTo: "user")
        .where(FieldPath.documentId, whereIn: doctorIds)
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
  } else {
    setState(() {
      userList = [];
      isLoading = false;
    });
  }
}

  void onSearch() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    setState(() {
      isLoading = true;
    });

    String searchText = _search.text.trim().toLowerCase();
    if (searchText.isEmpty) {
      setState(() {
        onLoadDoctors();
        isLoading = false;
      });
      return;
    }

    await firestore
        .collection('users')
        .where("role", isEqualTo: "user")
        .get()
        .then((value) {
      setState(() {
        userList = value.docs
            .where((doc) => doc['name'].toLowerCase().contains(searchText))
            .map((doc) => doc.data())
            .toList();
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
                  ),
                  SizedBox(
                    height: size.height / 60,
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Themes.buttonClr,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: toggleChattedUsers,
                    child: Text(
                      showChattedUsers ? "Hiển thị tất cả" : "Chỉ hiển thị đã chat",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  
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
                              leading: Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 30,
                                    backgroundImage: NetworkImage(
                                      user['imageURL'],
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
                                          user['status'] == 'online',
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
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
                              // subtitle: Text(
                              //   doctor['email'],
                              //   style: const TextStyle(
                              //     color: Colors.black54,
                              //     height: 1.5,
                              //   ),
                              // ),
                              trailing: const Icon(Icons.chat, color: Colors.black),
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
