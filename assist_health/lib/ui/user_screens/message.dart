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
    setStatus("online");
    onLoadDoctors();
  }

  void setStatus(String status) async {
    await _firestore.collection('users').doc(_auth.currentUser!.uid).update({
      "status": status,
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // online
      setStatus("online");
    } else {
      // offline
      setStatus("offline");
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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Themes.backgroundClr,
      appBar: AppBar(
        title: const Text("Hỏi đáp riêng cùng bác sĩ"),
        centerTitle: true,
        backgroundColor: Themes.hearderClr,
      ),
      body: isLoading
          ? Center(
              child: SizedBox(
                height: size.height / 20,
                width: size.height / 20,
                child: const CircularProgressIndicator(),
              ),
            )
          : Column(
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
                      backgroundColor: Themes.buttonClr),
                  onPressed: onSearch,
                  child: const Text("Tìm kiếm"),
                ),
                SizedBox(
                  height: size.height / 30,
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: doctorList.length,
                    itemBuilder: (context, index) {
                      Map<String, dynamic> doctor = doctorList[index];
                      return ListTile(
                        onTap: () {
                          String roomId = chatRoomId(
                              _auth.currentUser!.displayName!, doctor['name']);
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ChatRoom(
                                chatRoomId: roomId,
                                userMap: doctor,
                              ),
                            ),
                          );
                        },
                        leading:
                            const Icon(Icons.account_box, color: Colors.black),
                        title: Text(
                          doctor['name'],
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(doctor['email']),
                        trailing: const Icon(Icons.chat, color: Colors.black),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
