import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:assist_health/src/others/theme.dart';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:intl/intl.dart';

import 'model.dart';

class GeminiChatBot extends StatefulWidget {
  const GeminiChatBot({super.key});

  @override
  State<GeminiChatBot> createState() => _GeminiChatBotState();
}

class _GeminiChatBotState extends State<GeminiChatBot> {
  TextEditingController promptController = TextEditingController();
  static const apiKey = "YOUR_API_KEY";
  final model = GenerativeModel(model: "gemini-pro", apiKey: apiKey);

  final List<ModelMessage> messages = [];
  bool isGeneratingResponse = false;

  final ScrollController scrollController = ScrollController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    loadMessages();
  }

  Future<void> loadMessages() async {
    final snapshot =
        await _firestore.collection('gchatbot').orderBy('time').get();
    setState(() {
      for (var doc in snapshot.docs) {
        messages.add(ModelMessage(
          isPrompt: doc['isPrompt'],
          message: doc['message'],
          time: (doc['time'] as Timestamp).toDate(),
        ));
      }
    });
    _scrollToBottom();
  }

  Future<void> sendMessage() async {
    final message = promptController.text;
    setState(() {
      promptController.clear();
      messages.add(
        ModelMessage(
          isPrompt: true,
          message: message,
          time: DateTime.now(),
        ),
      );
      isGeneratingResponse = true;
    });
    await _firestore.collection('gchatbot').add({
      'isPrompt': true,
      'message': message,
      'time': DateTime.now(),
    });
    _scrollToBottom();
    if (message.toLowerCase().contains("xin chào") ||
        message.toLowerCase().contains("xin chao")) {
      setState(() {
        messages.add(
          ModelMessage(
            isPrompt: false,
            message:
                "Xin chào bạn! Tôi là một trợ lý ảo trong ứng dụng tư vấn sức khỏe. Tôi có thể giúp gì cho bạn?",
            time: DateTime.now(),
          ),
        );
        isGeneratingResponse = false;
      });
      await _firestore.collection('gchatbot').add({
        'isPrompt': false,
        'message':
            "Xin chào bạn! Tôi là một trợ lý ảo trong ứng dụng tư vấn sức khỏe. Tôi có thể giúp gì cho bạn?",
        'time': DateTime.now(),
      });
      _scrollToBottom();
      return;
    }
    if (message.toLowerCase().contains("bac si trong ung dung") ||
        message.toLowerCase().contains("bác sĩ trong ứng dụng")) {
      setState(() {
        messages.add(
          ModelMessage(
            isPrompt: false,
            message:
                "Dưới đây là danh sách các bác sĩ trong ứng dụng:\nBS. Trương Văn H (huyết học, hô hấp)\nBS. Nguyễn Văn B (nội thần kinh)\nBS. Nguyễn Văn A (mắt)\nBS. Huỳnh Tiến P (tim mạch)",
            time: DateTime.now(),
          ),
        );
        isGeneratingResponse = false;
      });
      await _firestore.collection('gchatbot').add({
        'isPrompt': false,
        'message':
            "Dưới đây là danh sách các bác sĩ trong ứng dụng:\nBS. Trương Văn H (huyết học, hô hấp)\nBS. Nguyễn Văn B (nội thần kinh)\nBS. Nguyễn Văn A (mắt)\nBS. Huỳnh Tiến P (tim mạch)",
        'time': DateTime.now(),
      });
      _scrollToBottom();
      return;
    }

    if (message.toLowerCase().contains("xe") ||
        message.toLowerCase().contains("xe")) {
      setState(() {
        messages.add(
          ModelMessage(
            isPrompt: false,
            message:
                "Xin lỗi tôi chỉ trả lời các câu hỏi trong phạm vi sức khỏe của ứng dụng",
            time: DateTime.now(),
          ),
        );
        isGeneratingResponse = false;
      });
      await _firestore.collection('gchatbot').add({
        'isPrompt': false,
        'message':
            "Xin lỗi tôi chỉ trả lời các câu hỏi trong phạm vi sức khỏe của ứng dụng",
        'time': DateTime.now(),
      });
      _scrollToBottom();
      return;
    }
    if (message.toLowerCase().contains("quan") ||
        message.toLowerCase().contains("quận")) {
      String response;
      if (message.toLowerCase().contains("quan 10") ||
          message.toLowerCase().contains("quận 10")) {
        response =
            "BS. Trương Văn H - Chuyên khoa (huyết học, hô hấp) - Địa chỉ: 123 Nguyễn Văn Linh, Phường 3, Quận 10";
      } else if (message.toLowerCase().contains("quận phú nhuận") ||
          message.toLowerCase().contains("quan phu nhuan")) {
        response =
            " BS. Nguyễn Văn B - Chuyên khoa (nội thần kinh) - Địa chỉ: 135A Huỳnh Ngọc Hay, phường 5, quận Phú Nhuận\nBS. Nguyễn Văn A - Chuyên khoa (mắt)- Địa chỉ: 999 Huỳnh Văn Bánh, phường 11, quận Phú Nhuận";
      } else if (message.toLowerCase().contains("quận 2") ||
          message.toLowerCase().contains("quan 2")) {
        response =
            "BS. Huỳnh Tiến P - Chuyên khoa (tim mạch) - Địa chi: 10 Trần Ngọc Diền, Thảo Điền, Quận 2";
      } else {
        response = "Hiện tại khu vực trên chưa có bác sĩ nào trong ứng dụng";
      }
      setState(() {
        messages.add(
          ModelMessage(
            isPrompt: false,
            message: response,
            time: DateTime.now(),
          ),
        );
        isGeneratingResponse = false;
      });
      await _firestore.collection('gchatbot').add({
        'isPrompt': false,
        'message': response,
        'time': DateTime.now(),
      });
      _scrollToBottom();
      return;
    }

    final content = [Content.text(message)];
    final response = await model.generateContent(content);
    setState(() {
      messages.add(
        ModelMessage(
          isPrompt: false,
          message: response.text ?? "",
          time: DateTime.now(),
        ),
      );
      isGeneratingResponse = false;
    });
    await _firestore.collection('gchatbot').add({
      'isPrompt': false,
      'message': response.text ?? "",
      'time': DateTime.now(),
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
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
            child: ListView.builder(
              controller: scrollController,
              itemCount: messages.length + (isGeneratingResponse ? 1 : 0),
              itemBuilder: (context, index) {
                if (index < messages.length) {
                  final message = messages[index];
                  return UserPrompt(
                    isPrompt: message.isPrompt,
                    message: message.message,
                    date: DateFormat('hh:mm a').format(
                      message.time,
                    ),
                  );
                } else {
                  return const TypingIndicator();
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(25),
            child: Row(
              children: [
                Expanded(
                  flex: 20,
                  child: TextField(
                    controller: promptController,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                    ),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      hintText: "Nhập tin nhắn",
                    ),
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: sendMessage,
                  child: const CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.blue,
                    child: Icon(
                      Icons.send,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Container UserPrompt({
    required final bool isPrompt,
    required String message,
    required String date,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      margin: const EdgeInsets.symmetric(vertical: 15).copyWith(
        left: isPrompt ? 80 : 15,
        right: isPrompt ? 15 : 80,
      ),
      decoration: BoxDecoration(
        color: isPrompt ? Colors.blue.shade400 : Colors.grey.shade200,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(20),
          topRight: const Radius.circular(20),
          bottomLeft: isPrompt ? const Radius.circular(20) : Radius.zero,
          bottomRight: isPrompt ? Radius.zero : const Radius.circular(20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message,
            style: TextStyle(
              fontWeight: isPrompt ? FontWeight.bold : FontWeight.normal,
              fontSize: 18,
              color: isPrompt ? Colors.white : Colors.black,
            ),
          ),
          Text(
            date,
            style: TextStyle(
              fontSize: 14,
              color: isPrompt ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

class TypingIndicator extends StatelessWidget {
  const TypingIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.all(15),
      margin: const EdgeInsets.symmetric(vertical: 15)
          .copyWith(left: 15, right: 80),
      child: const Text(
        'Đang nhắn...',
        style: TextStyle(
          fontSize: 18,
          fontStyle: FontStyle.italic,
          color: Colors.grey,
        ),
      ),
    );
  }
}
