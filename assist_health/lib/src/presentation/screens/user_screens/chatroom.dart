import 'dart:io';
import 'package:assist_health/src/others/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

// ignore: must_be_immutable
class ChatRoom extends StatefulWidget {
  final Map<String, dynamic> userMap;
  final String chatRoomId;
  bool isUser;

  ChatRoom(
      {super.key,
      required this.chatRoomId,
      required this.userMap,
      required this.isUser});

  @override
  State<ChatRoom> createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  final TextEditingController _message = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<File>? imageFiles = [];
  String name = 'Đang tải...';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future getImages() async {
    ImagePicker picker = ImagePicker();

    await picker.pickMultiImage().then((List<XFile> xFiles) {
      if (xFiles.isNotEmpty) {
        imageFiles = xFiles.map((xFile) => File(xFile.path)).toList();
        _uploadImages();
      }
    });
  }

  Future _uploadImages() async {
    for (File imageFile in imageFiles!) {
      String fileName = const Uuid().v1();
      int status = 1;

      await _firestore
          .collection('chatroom')
          .doc(widget.chatRoomId)
          .collection('chats')
          .doc(fileName)
          .set({
        "sendby": _auth.currentUser!.displayName,
        "message": "",
        "type": "img",
        "time": FieldValue.serverTimestamp(),
      });

      var ref =
          FirebaseStorage.instance.ref().child('images').child("$fileName.jpg");

      SettableMetadata metadata = SettableMetadata(
        contentType: 'image/jpeg',
      );
      var uploadTask =
          // ignore: body_might_complete_normally_catch_error
          await ref.putFile(imageFile, metadata).catchError((error) async {
        _firestore
            .collection('chatroom')
            .doc(widget.chatRoomId)
            .collection('chats')
            .doc(fileName)
            .delete();
        status = 0;
      });

      if (status == 1) {
        String imageUrl = await uploadTask.ref.getDownloadURL();

        await _firestore
            .collection('chatroom')
            .doc(widget.chatRoomId)
            .collection('chats')
            .doc(fileName)
            .update({"message": imageUrl});
      }
    }
  }

  void onSendMessage() async {
    if (_message.text.isNotEmpty) {
      Map<String, dynamic> messages = {
        "sendby": _auth.currentUser!.displayName,
        "message": _message.text,
        "type": "text",
        "time": FieldValue.serverTimestamp(),
      };

      _message.clear();
      await _firestore
          .collection('chatroom')
          .doc(widget.chatRoomId)
          .collection('chats')
          .add(messages);
    } else {
      debugPrint("Enter Some Text");
    }
  }

  Future<void> _loadUserData() async {
    try {
      final userSnapshot =
          await _firestore.collection("users").doc(widget.userMap['uid']).get();

      if (userSnapshot.exists) {
        final userData = userSnapshot.data() as Map<String, dynamic>?;

        if (userData != null) {
          if (userData['role'] == 'admin') {
            name = 'Chăm Sóc Khách Hàng';
          } else if (userData['role'] == 'user') {
            final profileSnapshot = await _firestore
                .collection("users")
                .doc(widget.userMap['uid'])
                .collection("health_profiles")
                .doc("main_profile")
                .get();

            if (profileSnapshot.exists) {
              final profileData =
                  profileSnapshot.data() as Map<String, dynamic>?;
              name = profileData?['name'] ?? 'Không rõ';
            } else {
              name = 'Không rõ';
            }
          } else {
            name = userData['name'] ?? 'Không rõ';
          }
        }
      } else {
        name = 'Không tìm thấy dữ liệu';
      }
    } catch (e) {
      name = 'Lỗi khi tải dữ liệu';
    }

    // Cập nhật lại giao diện sau khi load xong dữ liệu
    if (mounted) {
      setState(() {});
    }
  }

  Widget _buildTitle(String name) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          (name != 'Chăm Sóc Khách Hàng')
              ? (widget.isUser)
                  ? 'Người dùng $name'
                  : 'Bác sĩ $name'
              : name,
          style: const TextStyle(fontSize: 18),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Themes.gradientDeepClr, Themes.gradientLightClr],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
        foregroundColor: Colors.white,
        title: _buildTitle(name),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).viewInsets.bottom > 0
                  ? size.height -
                      MediaQuery.of(context).viewInsets.bottom -
                      -65 -
                      210
                  : size.height / 1.2,
              width: size.width,
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('chatroom')
                    .doc(widget.chatRoomId)
                    .collection('chats')
                    .orderBy("time", descending: false)
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.data != null) {
                    return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        Map<String, dynamic> map = snapshot.data!.docs[index]
                            .data() as Map<String, dynamic>;
                        return messages(size, map, context);
                      },
                    );
                  } else {
                    return Container();
                  }
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        height: 65,
        margin:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[200],
        ),
        child: Row(
          children: [
            IconButton(
              onPressed: getImages,
              icon: const Icon(Icons.image),
              color: Colors.blue,
            ),
            Expanded(
              child: TextField(
                controller: _message,
                decoration: const InputDecoration(
                  hintText: 'Nhắn tin',
                  border: InputBorder.none,
                ),
              ),
            ),
            IconButton(
              onPressed: onSendMessage,
              icon: const Icon(Icons.send),
              color: Colors.blue,
            ),
          ],
        ),
      ),
    );
  }

  Widget messages(Size size, Map<String, dynamic> map, BuildContext context) {
    final isSentByMe = map['sendby'] == _auth.currentUser!.displayName;

    return map['type'] == "text"
        ? Container(
            width: size.width,
            alignment:
                isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width < 300
                    ? MediaQuery.of(context).size.width
                    : 300,
              ),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
              margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: isSentByMe
                    ? Colors.blue
                    : const Color.fromARGB(
                        255, 231, 223, 223), // Customize the colors here
              ),
              child: Text(
                map['message'],
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isSentByMe
                      ? Colors.white
                      : Colors.black, // Customize the text color here
                ),
              ),
            ),
          )
        : Container(
            height: size.height / 2.5,
            width: size.width,
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
            alignment:
                isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
            child: InkWell(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ShowImage(
                    imageUrl: map['message'],
                  ),
                ),
              ),
              child: Container(
                height: size.height / 2.5,
                width: size.width / 2,
                decoration: BoxDecoration(border: Border.all()),
                alignment: map['message'] != "" ? null : Alignment.center,
                child: map['message'] != ""
                    ? Image.network(
                        map['message'],
                        fit: BoxFit.cover,
                      )
                    : const CircularProgressIndicator(),
              ),
            ),
          );
  }
}

class ShowImage extends StatelessWidget {
  final String imageUrl;

  const ShowImage({required this.imageUrl, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        height: size.height,
        width: size.width,
        color: Colors.black,
        child: Image.network(imageUrl),
      ),
    );
  }
}
