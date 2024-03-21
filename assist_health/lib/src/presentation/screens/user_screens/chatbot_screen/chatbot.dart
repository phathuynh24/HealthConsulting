import 'dart:convert';
import 'dart:math';
import 'package:assist_health/src/models/other/message.dart';
import 'package:assist_health/src/others/theme.dart';
import 'package:chat_bubbles/bubbles/bubble_normal.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController controller = TextEditingController();
  ScrollController scrollController = ScrollController();
  List<Message> msgs = [];
  bool isTyping = false;

  String messageRequired = "";
  // String messageRequired = "If the question is not related to medical or health inquiries, kindly respond with the following: " +
  //     "'I'm sorry, I can only assist with answering questions related to medical or health topics.' " +
  //     "Additionally, for inquiries about who you are, kindly reply with: 'I am the 'Health Assistant,' " +
  //     "a virtual assistant created with the goal of providing accurate and helpful information about health, medicine, and related issues. " +
  //     "I can answer questions about pregnancy, diabetes, various medical conditions, health, healthy lifestyles, medicine, and relationships. " +
  //     "However, I cannot provide personal information or information unrelated to the field of health and medicine.' " +
  //     "If the received message is a complaint, I apologize for any inconvenience. " +
  //     "If the message indicates that there is no illness or health-related concern, I would like to extend my best wishes. " +
  //     "Please consider me as your Health Assistant, here to assist with any medical or health-related questions you may have.";

  void sendMsg() async {
    String text = controller.text;
    String apiKey = "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";
    controller.clear();
    try {
      if (text.isNotEmpty) {
        setState(() {
          msgs.insert(0, Message(true, text));
          isTyping = true;
        });
        scrollController.animateTo(0.0,
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
                {"role": "user", "content": text},
              ]
            }));
        if (response.statusCode == 200) {
          var json = jsonDecode(utf8.decode(response.bodyBytes));
          setState(() {
            isTyping = false;
            msgs.insert(
                0,
                Message(
                    false,
                    json["choices"][0]["message"]["content"]
                        .toString()
                        .trimLeft()));
          });
          scrollController.animateTo(0.0,
              duration: const Duration(seconds: 1), curve: Curves.easeOut);
        }
      }
    } on Exception {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Some error occurred, please try again!")));
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
          // Chat view
          Expanded(
            child: ListView.builder(
                controller: scrollController,
                itemCount: msgs.length,
                shrinkWrap: true,
                reverse: true,
                itemBuilder: (context, index) {
                  return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: isTyping && index == 0
                          ? Column(
                              children: [
                                BubbleNormal(
                                  text: msgs[0].msg,
                                  isSender: true,
                                  color: Colors.blue.shade100,
                                ),
                                const Padding(
                                  padding: EdgeInsets.only(left: 16, top: 4),
                                  child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text("Đang nhắn...")),
                                )
                              ],
                            )
                          : BubbleNormal(
                              text: msgs[index].msg,
                              isSender: msgs[index].isSender,
                              color: msgs[index].isSender
                                  ? Colors.blue.shade100
                                  : Colors.grey.shade200,
                            ));
                }),
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
                        borderRadius: BorderRadius.circular(10)),
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
                            hintText: "Nhập tin nhắn"),
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
                      borderRadius: BorderRadius.circular(30)),
                  child: const Icon(
                    Icons.send,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(
                width: 8,
              )
            ],
          ),
        ],
      ),
    );
  }
}
