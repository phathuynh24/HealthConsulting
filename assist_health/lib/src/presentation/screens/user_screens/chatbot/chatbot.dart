import 'dart:convert';
import 'package:assist_health/src/models/other/message.dart';
import 'package:assist_health/src/others/theme.dart';
import 'package:chat_bubbles/bubbles/bubble_normal.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  TextEditingController controller = TextEditingController();
  ScrollController scrollController = ScrollController();
  List<Message> msgs = [];
  bool isTyping = false;

  @override
  void initState() {
    super.initState();
  }

  void sendMsg() async {
    String text = controller.text;
    String? apiKey = dotenv.env['CHATBOT_API_KEY'] ?? "";
    controller.clear();
    try {
      if (text.isNotEmpty) {
        setState(() {
          msgs.add(Message(true, text));
          isTyping = true;
        });

        Map<String, dynamic> messages = {
          "sendby": _auth.currentUser!.displayName,
          "message": text,
          "type": "text",
          "time": FieldValue.serverTimestamp(),
        };

        await _firestore
            .collection('chatbot')
            .doc(_auth.currentUser!.uid)
            .collection('chats')
            .add(messages);

        scrollController.animateTo(scrollController.position.maxScrollExtent,
            duration: const Duration(seconds: 1), curve: Curves.easeOut);
        var response = await http.post(
            Uri.parse("https://api.openai.com/v1/chat/completions"),
            headers: {
              "Authorization": "Bearer $apiKey",
              "Content-Type": "application/json"
            },
            body: jsonEncode({
              "model": "gpt-3.5-turbo-0125",
              "messages": [
                {
                  "role": "system",
                  "content":
                      "I am a friendly and helpful \"health assistant\" focused on providing accurate and useful information about health, diseases, medical issues, and healthy lifestyle. I can help users understand health-related matters better, answer their questions, and provide advice on healthcare. I won't respond to requests or questions that are unrelated to health"
                },
                {
                  "role": "user",
                  "content":
                      "Use Vietnamese languge and if the question is not directly related to the medical or health topic, politely reject it"
                },
                {"role": "user", "content": text},
              ]
            }));

        if (response.statusCode == 200) {
          var json = jsonDecode(utf8.decode(response.bodyBytes));
          String reply =
              json["choices"][0]["message"]["content"].toString().trimLeft();
          setState(() {
            isTyping = false;
            msgs.add(Message(false, reply));
          });

          Map<String, dynamic> messages = {
            "sendby": "assistant",
            "message": reply,
            "type": "text",
            "time": FieldValue.serverTimestamp(),
          };

          await _firestore
              .collection('chatbot')
              .doc(_auth.currentUser!.uid)
              .collection('chats')
              .add(messages);

          scrollController.animateTo(scrollController.position.maxScrollExtent,
              duration: const Duration(seconds: 1), curve: Curves.easeOut);
        }
      }
    } on Exception {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Some error occurred, please try again!")));
    }
  }

  void _scrollToBottom() {
    if (scrollController.hasClients) {
      double offset = scrollController.position.maxScrollExtent + 3000;
      scrollController.jumpTo(offset);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: const Text('Chat Bot'),
        elevation: 0,
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
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('chatbot')
                  .doc(_auth.currentUser!.uid)
                  .collection('chats')
                  .orderBy("time", descending: false)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (snapshot.hasError) {
                  return const Center(
                    child: Text('Error occurred while loading data.'),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text('No messages available.'),
                  );
                }
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollToBottom();
                });
                return ListView.builder(
                  controller: scrollController,
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    Map<String, dynamic> map = snapshot.data!.docs[index].data()
                        as Map<String, dynamic>;
                    final isSentByMe =
                        map['sendby'] == _auth.currentUser!.displayName;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Column(
                        children: [
                          BubbleNormal(
                            text: map["message"],
                            isSender: isSentByMe,
                            color: isSentByMe
                                ? Colors.blue.shade100
                                : Colors.grey.shade200,
                          ),
                          if (isTyping &&
                              index == snapshot.data!.docs.length - 1)
                            const Padding(
                              padding: EdgeInsets.only(left: 16, top: 4),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text("Đang nhắn..."),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          // Chat input
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: TextField(
                        controller: controller,
                        textCapitalization: TextCapitalization.sentences,
                        onSubmitted: (value) {
                          sendMsg();
                        },
                        textInputAction: TextInputAction.send,
                        showCursor: true,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: "Nhập tin nhắn",
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  sendMsg();
                },
                child: Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Icon(
                    Icons.send,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
        ],
      ),
    );
  }
}
