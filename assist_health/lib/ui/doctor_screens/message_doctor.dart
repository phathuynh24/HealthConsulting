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
  List<Map<String, dynamic>> adminList = [];
  bool isLoading = false;
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
 



  void onSearch() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    setState(() {
      isLoading = true;
      userList=[];
    });

    String searchText = _search.text.trim().toLowerCase();
    if (searchText.isEmpty) {
      setState(() {
        onLoadUsers();
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

  void onLoadUsers() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    setState(() {
      isLoading = true;
    });

    await firestore
        .collection('users')
        .where("role", whereIn: ["user", "admin"])
        .get()
        .then((value) {
      if (value.docs.isNotEmpty) {
        setState(() {
          userList = value.docs
              .where((doc) => doc['role'] == 'user')
              .map((doc) => doc.data())
              .toList();
          adminList = value.docs
              .where((doc) => doc['role'] == 'admin')
              .map((doc) => doc.data())
              .toList();
          isLoading = false;
        });
      } else {
        setState(() {
          userList = [];
          adminList = [];
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
        title: const Text('Thảo luận với người dùng'),
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
                  
                  if (adminList.isNotEmpty)
                    Container(
                      child: Column(
                        children: [
                       
                          ListView.builder(
                            shrinkWrap: true,
                            itemCount: adminList.length,
                            itemBuilder: (context, index) {
                              Map<String, dynamic> admin = adminList[index];
                              return Column(
                                children: [
                                  ListTile(
                                    onTap: () {
                                      String roomId = chatRoomId(
                                        _auth.currentUser!.displayName!,
                                        admin['name'],
                                      );
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => ChatRoom(
                                            chatRoomId: roomId,
                                            userMap: admin,
                                          ),
                                        ),
                                      );
                                    },
                                    leading: Stack(
                                      children: [
                                        CircleAvatar(
                                          radius: 30,
                                          backgroundImage: NetworkImage(
                                            admin['imageURL'],
                                          ),
                                        )
                                      ],
                                    ),
                                    title: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Chăm Sóc Khách Hàng',
                                          style: const TextStyle(
                                            color: Colors.black,
                                            height: 1.5,
                                            fontSize: 17,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Text(
                                          'Thứ 2 -Thứ 7: 8h30 - 17h30',
                                          style: const TextStyle(
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
                                    Divider(
                                      color: Colors.grey,
                                      thickness: 1.0,
                                    ),
                                ],
                              );
                            },
                          ),
                          Divider(
                                      color: Colors.grey,
                                      thickness: 5.0,
                                    ),
                        ],
                      ),
                    ),

                  if (userList.isNotEmpty)
                    Container(
                      child: Column(
                        children: [
                          Text(
                            'Danh sách bác sĩ',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          Container(
                            width: 200.0,  
                            child: Divider(
                            color: const Color.fromARGB(255, 179, 35, 35),
                            thickness: 3.0,
                                ),
                          ),
                          ListView.builder(
                            shrinkWrap: true,
                            itemCount: userList.length,
                            itemBuilder: (context, index) {
                              Map<String, dynamic> doctor = userList[index];
                              return Column(
                                children: [
                                  ListTile(
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
                                    trailing: const Icon(Icons.chat, color: Colors.black),
                                  ),
                                  if (index < userList.length - 1)
                                    Divider(
                                      color: Colors.grey,
                                      thickness: 1.0,
                                      
                                    ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}