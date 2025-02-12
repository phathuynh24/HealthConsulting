// ignore_for_file: avoid_print, use_build_context_synchronously

import 'dart:async';

import 'package:assist_health/src/models/other/chat.dart';
import 'package:assist_health/src/others/theme.dart';
import 'package:assist_health/src/presentation/screens/user_screens/chatroom.dart';
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
  List<Map<String, dynamic>> userRooms = [];
  List<Map<String, dynamic>> doctorRooms = [];
  bool isLoading = false;
  bool isGoToChatRoom = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _searchController = TextEditingController();
  bool _isActive = true; // Track widget status

  StreamSubscription? _chatRoomSubscription;

  @override
  void initState() {
    super.initState();
    getChatRooms();
  }

  @override
  void dispose() {
    _isActive = false;
    _chatRoomSubscription?.cancel(); // Cancel Stream
    _searchController.dispose();
    super.dispose();
  }

  Future<void> getChatRooms() async {
    if (!_isActive) return;

    setState(() {
      isLoading = true;
    });

    try {
      _chatRoomSubscription = _firestore
          .collection('chatroom')
          .where('idDoctor', isEqualTo: _auth.currentUser!.uid)
          .snapshots()
          .listen((snapshot) async {
        chatRoomList =
            snapshot.docs.map((doc) => Chat.fromJson(doc.data())).toList();

        await classifyChatRooms();

        if (_isActive) {
          setState(() {
            isLoading = false;
          });
        }
      });
    } catch (error) {
      print("Error loading chat rooms: $error");
      if (_isActive) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> classifyChatRooms() async {
    List<Map<String, dynamic>> tempUserRooms = [];
    List<Map<String, dynamic>> tempDoctorRooms = [];

    for (var chat in chatRoomList) {
      final userSnapshot =
          await _firestore.collection('users').doc(chat.idUser).get();

      final role = userSnapshot.data()?['role'] ?? 'unknown';
      final userData = userSnapshot.data();
      String name = 'Không rõ';

      if (role == 'user') {
        // Lấy name từ main_profile của user
        final mainProfileSnapshot = await _firestore
            .collection('users')
            .doc(chat.idUser)
            .collection('health_profiles')
            .doc('main_profile')
            .get();

        name = mainProfileSnapshot.data()?['name'] ?? 'Không rõ';

        tempUserRooms.add({'chat': chat, 'userData': userData, 'name': name});
      } else if (role == 'doctor') {
        // Lấy name từ document của doctor
        name = userData?['name'] ?? 'Không rõ';
        tempDoctorRooms.add({'chat': chat, 'userData': userData, 'name': name});
      }
    }

    if (_isActive) {
      setState(() {
        userRooms = tempUserRooms;
        doctorRooms = tempDoctorRooms;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            foregroundColor: Colors.white,
            title: const Text('Tin nhắn'),
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
          ),
          body: isLoading
              ? const Center(child: CircularProgressIndicator())
              : DefaultTabController(
                  length: 2,
                  child: Column(
                    children: [
                      const TabBar(
                        tabs: [
                          Tab(text: 'Bệnh nhân'),
                          Tab(text: 'Bác sĩ'),
                        ],
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            buildChatList(userRooms, true),
                            buildChatList(doctorRooms, false),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
        ),
        if (isGoToChatRoom)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: const Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }

  Widget buildChatList(List<Map<String, dynamic>> rooms, bool isUser) {
    if (rooms.isEmpty) {
      return const Center(child: Text('Không có phòng chat nào.'));
    }

    return ListView.builder(
      itemCount: rooms.length,
      itemBuilder: (context, index) {
        final chatRoom = rooms[index]['chat'];
        final userData = rooms[index]['userData'];
        final name = rooms[index]['name'];

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ListTile(
            leading: CircleAvatar(
              radius: 30,
              backgroundColor: Colors.grey[200],
              backgroundImage:
                  (userData?['imageURL'] != null && userData?['imageURL'] != '')
                      ? NetworkImage(userData!['imageURL'])
                      : null,
              child:
                  (userData?['imageURL'] == null || userData?['imageURL'] == '')
                      ? const Icon(Icons.person, size: 30, color: Colors.grey)
                      : null,
            ),
            title: Text(
              isUser ? 'Người dùng: $name' : 'Bác sĩ: $name',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: Text(
              'ID phòng: ${chatRoom.idDoc}',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
            onTap: () {
              if (_isActive) {
                isUser
                    ? goToChatRoomUser(chatRoom.idUser, userData)
                    : goToChatRoomDoctor(chatRoom.idUser, userData);
              }
            },
          ),
        );
      },
    );
  }

  Future<void> goToChatRoomUser(
      String id, Map<String, dynamic>? userData) async {
    try {
      setState(() {
        isGoToChatRoom = true;
      });
      final mainProfileSnapshot = await _firestore
          .collection('users')
          .doc(id)
          .collection('health_profiles')
          .doc('main_profile')
          .get();

      final name = mainProfileSnapshot.data()?['name'] ?? 'Không rõ';

      final querySnapshot = await _firestore
          .collection('chatroom')
          .where('idProfile', isEqualTo: id)
          .where('idDoctor', isEqualTo: _auth.currentUser!.uid)
          .where('idUser', isEqualTo: id)
          .get();

      if (querySnapshot.docs.isNotEmpty && _isActive) {
        String chatRoomId = querySnapshot.docs[0].id;

        if (!mounted) return;
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ChatRoom(
              chatRoomId: chatRoomId,
              userMap: userData ?? {'name': name},
              isUser: true,
            ),
          ),
        );
      }
    } catch (e) {
      print('Lỗi khi vào phòng chat: $e');
    } finally {
      if (_isActive) {
        setState(() {
          isGoToChatRoom = false;
        });
      }
    }
  }

  Future<void> goToChatRoomDoctor(
      String id, Map<String, dynamic>? userData) async {
    try {
      setState(() {
        isGoToChatRoom = true;
      });
      final userSnapshot = await _firestore.collection('users').doc(id).get();
      final name = userSnapshot.data()?['name'] ?? 'Không rõ';

      final querySnapshot = await _firestore
          .collection('chatroom')
          .where('idProfile', isEqualTo: id)
          .where('idDoctor', isEqualTo: _auth.currentUser!.uid)
          .where('idUser', isEqualTo: id)
          .get();

      if (querySnapshot.docs.isNotEmpty && _isActive) {
        String chatRoomId = querySnapshot.docs[0].id;

        if (!mounted) return;
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ChatRoom(
              chatRoomId: chatRoomId,
              userMap: userData ?? {'name': name},
              isUser: false,
            ),
          ),
        );
      }
    } catch (e) {
      print('Lỗi khi vào phòng chat: $e');
    } finally {
      if (_isActive) {
        setState(() {
          isGoToChatRoom = false;
        });
      }
    }
  }
}
