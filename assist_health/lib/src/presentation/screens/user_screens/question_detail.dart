// ignore_for_file: avoid_print

import 'dart:io';

import 'package:assist_health/src/presentation/screens/user_screens/community.dart';
import 'package:assist_health/src/presentation/screens/user_screens/meals/widgets/loading_indicator.dart';
import 'package:assist_health/src/widgets/my_separator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:assist_health/src/others/theme.dart';
import 'package:assist_health/src/models/other/question.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class QuestionDetailScreen extends StatefulWidget {
  final Question question;

  const QuestionDetailScreen({super.key, required this.question});

  @override
  State<QuestionDetailScreen> createState() => _QuestionDetailScreenState();
}

class _QuestionDetailScreenState extends State<QuestionDetailScreen> {
  List<Map<String, dynamic>> answers = [];
  late User currentUser;
  late String? currentUserRole;
  Question question = Question.initial();
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    question = widget.question;
    _loadAnswers();
    _loadCurrentUserRole();
    currentUserRole = '';
    currentUser = FirebaseAuth.instance.currentUser!;
  }

  void _loadCurrentUserRole() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get()
          .then((docSnapshot) {
        if (docSnapshot.exists) {
          setState(() {
            currentUserRole = docSnapshot.data()?['role'] ?? '';
          });
        }
      }).catchError((error) {
        print('Failed to load user role: $error');
      });
    }
  }

  void _loadAnswers() {
    FirebaseFirestore.instance
        .collection('questions')
        .doc(question.id)
        .get()
        .then((docSnapshot) {
      if (docSnapshot.exists) {
        setState(() {
          answers = List<Map<String, dynamic>>.from(
              docSnapshot.data()?['answers'] ?? []);
        });
      }
    }).catchError((error) {
      print('Failed to load answers: $error');
    });
  }

  Widget _buildUserAction(Map<String, dynamic> answerData) {
    if (currentUser.uid == answerData['userId']) {
      return Row(
        children: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.blue),
            onPressed: () => _showAnswerDialog(context, answerData: answerData),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _deleteAnswer(answerData),
          ),
        ],
      );
    } else {
      return const SizedBox(); // Trả về widget rỗng nếu không phải tin nhắn của mình
    }
  }

  void _deleteAnswer(Map<String, dynamic> answerData) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Xác nhận xóa'),
          content: const Text('Bạn có chắc chắn muốn xóa câu trả lời này?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('questions')
                    .doc(question.id)
                    .update({
                  'answers': FieldValue.arrayRemove([answerData]),
                });

                Navigator.pop(context);
                _loadAnswers();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Xóa'),
            ),
          ],
        );
      },
    );
  }

  void _showAnswerDialog(BuildContext context,
      {Map<String, dynamic>? answerData}) {
    TextEditingController answerController = TextEditingController(
      text: answerData != null ? answerData['answer'] : '',
    );
    File? selectedImage;
    String? existingImageUrl =
        answerData != null ? answerData['imageUrl'] : null;
    bool isSaving = false; // Biến để theo dõi trạng thái lưu dữ liệu

    Future<String?> uploadImage(File image) async {
      try {
        final ref = FirebaseStorage.instance.ref().child(
              'answer_images/${DateTime.now().millisecondsSinceEpoch}_${image.path.split('/').last}',
            );
        SettableMetadata metadata = SettableMetadata(
          contentType: 'image/jpeg',
        );
        await ref.putFile(image, metadata);
        return await ref.getDownloadURL();
      } catch (e) {
        debugPrint('Error uploading image: $e');
        return null;
      }
    }

    showDialog(
      context: context,
      barrierDismissible:
          false, // ❌ Không cho phép đóng dialog khi bấm ra ngoài
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return WillPopScope(
              onWillPop: () async =>
                  !isSaving, // ❌ Không cho phép bấm nút back khi đang lưu
              child: AlertDialog(
                title: Text(answerData != null
                    ? 'Chỉnh sửa câu trả lời'
                    : 'Thêm câu trả lời'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: answerController,
                      maxLines: 5,
                      enabled: !isSaving, // ❌ Không cho phép nhập khi đang lưu
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Nhập câu trả lời',
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: isSaving
                          ? null
                          : () async {
                              final pickedFile = await ImagePicker()
                                  .pickImage(source: ImageSource.gallery);
                              if (pickedFile != null) {
                                setState(() {
                                  selectedImage = File(pickedFile.path);
                                  existingImageUrl = null;
                                });
                              }
                            },
                      icon: Icon(
                        selectedImage != null || existingImageUrl != null
                            ? Icons.check_circle
                            : Icons.image,
                        color: selectedImage != null || existingImageUrl != null
                            ? Colors.green
                            : Colors.white,
                      ),
                      label: Text(
                        selectedImage != null || existingImageUrl != null
                            ? 'Đã chọn ảnh'
                            : 'Chọn ảnh',
                        style: TextStyle(
                          color:
                              selectedImage != null || existingImageUrl != null
                                  ? Colors.green
                                  : Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            selectedImage != null || existingImageUrl != null
                                ? Colors.white
                                : Colors.blue,
                        side: selectedImage != null || existingImageUrl != null
                            ? const BorderSide(color: Colors.green)
                            : null,
                      ),
                    ),
                    if (isSaving) // ✅ Hiển thị loading khi đang lưu dữ liệu
                      const Padding(
                        padding: EdgeInsets.only(top: 10),
                        child: CircularProgressIndicator(),
                      ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: isSaving ? null : () => Navigator.pop(context),
                    child: const Text('Hủy'),
                  ),
                  ElevatedButton(
                    onPressed: isSaving
                        ? null
                        : () async {
                            setState(() {
                              isSaving = true; // ✅ Bắt đầu trạng thái loading
                            });

                            String answer = answerController.text.trim();
                            String? imageUrl;

                            if (selectedImage != null) {
                              imageUrl = await uploadImage(selectedImage!);
                            } else if (existingImageUrl != null) {
                              imageUrl = existingImageUrl;
                            }

                            if (answer.isNotEmpty || imageUrl != null) {
                              if (answerData != null) {
                                await FirebaseFirestore.instance
                                    .collection('questions')
                                    .doc(question.id)
                                    .update({
                                  'answers':
                                      FieldValue.arrayRemove([answerData]),
                                });

                                answerData['answer'] = answer;
                                if (imageUrl != null) {
                                  answerData['imageUrl'] = imageUrl;
                                }

                                await FirebaseFirestore.instance
                                    .collection('questions')
                                    .doc(question.id)
                                    .update({
                                  'answers':
                                      FieldValue.arrayUnion([answerData]),
                                });
                              } else {
                                await _saveAnswerToFirebase(answer, imageUrl);
                              }
                            }

                            setState(() {
                              isSaving = false; // ✅ Kết thúc trạng thái loading
                            });
                            Navigator.pop(context);
                            _loadAnswers();
                          },
                    child: Text(answerData != null ? 'Lưu' : 'Thêm'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showDeleteTopicConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Xác nhận xóa chủ đề'),
          content: const Text('Bạn có chắc chắn muốn xóa chủ đề này không?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('questions')
                    .doc(question.id)
                    .delete();
                Navigator.pop(context);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Xóa'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('dd/MM/yyyy').format(question.date!);
    // Sắp xếp câu trả lời từ cũ nhất đến mới nhất
    List<Map<String, dynamic>> sortedAnswers = List.from(answers);

    sortedAnswers.sort((a, b) {
      DateTime timeA = a['timestamp'] != null
          ? (a['timestamp'] as Timestamp).toDate()
          : DateTime.fromMillisecondsSinceEpoch(0);

      DateTime timeB = b['timestamp'] != null
          ? (b['timestamp'] as Timestamp).toDate()
          : DateTime.fromMillisecondsSinceEpoch(0);

      return timeA.compareTo(timeB); // Sắp xếp tăng dần (cũ nhất ở trên)
    });
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Themes.backgroundClr,
          appBar: AppBar(
            foregroundColor: Colors.white,
            title: const Text(
              'Chi tiết câu hỏi',
              style: TextStyle(fontSize: 20),
            ),
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
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  leading: CircleAvatar(
                    child: Icon(
                      Icons.person,
                      size: 30,
                      color: Colors.purple.withOpacity(0.5),
                    ),
                  ),
                  title: Text(
                    '${question.gender}, ${question.age} tuổi',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    formattedDate,
                    style: const TextStyle(
                      fontSize: 15,
                    ),
                  ),
                  trailing: (currentUser.uid == question.questionUserId)
                      ? PopupMenuButton<String>(
                          onSelected: (value) async {
                            if (value == 'edit') {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CommunityScreen(
                                    questionToEdit: question,
                                  ),
                                ),
                              );

                              if (result != null &&
                                  result is Map<String, dynamic>) {
                                setState(() {
                                  // Sử dụng đúng instance của question để gọi copyWith
                                  question = question.copyWith(result);
                                });
                              }
                            } else if (value == 'delete') {
                              _showDeleteTopicConfirmationDialog();
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Text('Chỉnh sửa'),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text('Xóa'),
                            ),
                          ],
                        )
                      : null,
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Chủ đề: ${question.title}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Nội dung: ${question.content}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          height: 1.5,
                        ),
                      ),
                      if (question.imageUrls.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: question.imageUrls.map((url) {
                              return GestureDetector(
                                onTap: () => _showFullImage(url),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    url,
                                    height: 170,
                                    width: 170,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                    ],
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: question.categories
                        .map((category) => Padding(
                              padding: const EdgeInsets.only(left: 16),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Themes.gradientLightClr,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Text(
                                  category,
                                  style: const TextStyle(
                                      fontSize: 14, color: Colors.white),
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                const Divider(
                  color: Colors.grey,
                  thickness: 0.5,
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Câu trả lời (${answers.length}):',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: sortedAnswers.length,
                  itemBuilder: (context, index) {
                    Map<String, dynamic> answerData = sortedAnswers[index];
                    String answer = answerData['answer'];
                    String userId = answerData['userId'];

                    // Kiểm tra và định dạng timestamp
                    String formattedTimestamp = '';
                    if (answerData.containsKey('timestamp') &&
                        answerData['timestamp'] != null) {
                      DateTime timestamp =
                          (answerData['timestamp'] as Timestamp).toDate();
                      formattedTimestamp =
                          DateFormat('HH:mm:ss dd/MM/yyyy').format(timestamp);
                    } else {
                      formattedTimestamp = 'Thời gian trống';
                    }

                    return ListTile(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16),
                      tileColor: Colors.grey[100],
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      title: FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance
                            .collection('users')
                            .doc(userId)
                            .get(),
                        builder: (BuildContext context,
                            AsyncSnapshot<DocumentSnapshot> snapshot) {
                          if (snapshot.hasError) {
                            return const Text('Error loading user data');
                          }

                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            Map<String, dynamic> userData =
                                snapshot.data!.data() as Map<String, dynamic>;
                            String imageUrl = userData['imageURL'];
                            bool isAnswererAuthor =
                                question.questionUserId == userId;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ListTile(
                                  leading: isAnswererAuthor
                                      ? CircleAvatar(
                                          child: Icon(
                                            Icons.person,
                                            size: 30,
                                            color:
                                                Colors.purple.withOpacity(0.5),
                                          ),
                                        )
                                      : CircleAvatar(
                                          backgroundImage:
                                              NetworkImage(imageUrl),
                                        ),
                                  title: Text(
                                    isAnswererAuthor
                                        ? '${question.gender}, ${question.age} tuổi'
                                        : currentUserRole == 'admin'
                                            ? 'Quản trị viên'
                                            : 'Bác sĩ ${userData['name']}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  subtitle: Text(
                                    formattedTimestamp,
                                    style: const TextStyle(
                                        fontSize: 14, color: Colors.grey),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (currentUserRole == 'admin')
                                        IconButton(
                                          onPressed: () {
                                            _showDeleteConfirmationDialog(
                                                answerData);
                                          },
                                          icon: const Icon(Icons.delete),
                                          color: Colors.red,
                                        ),
                                      _buildUserAction(answerData),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  child: Text(
                                    answer,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                                if (answerData['imageUrl'] != null)
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 8.0, left: 16),
                                    child: GestureDetector(
                                      onTap: () {
                                        _showFullImage(answerData['imageUrl']);
                                      },
                                      child: Image.network(
                                        answerData['imageUrl'],
                                        height: 150,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                const SizedBox(height: 8),
                                const MySeparator(color: Colors.grey),
                              ],
                            );
                          }
                          return const Center(
                              child: CircularProgressIndicator());
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          bottomNavigationBar: (question.questionUserId == currentUser.uid ||
                  currentUserRole == "doctor")
              ? Container(
                  height: 70,
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 10,
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      top: BorderSide(
                        color: Colors.blueGrey,
                        width: 0.2,
                      ),
                    ),
                  ),
                  child: GestureDetector(
                    onTap: () {
                      _showAnswerDialog(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(13),
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      decoration: BoxDecoration(
                        color: Themes.gradientDeepClr,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'Thêm tin nhắn',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                )
              : null,
        ),
        if (isSaving)
          Container(
            color: Colors.black.withOpacity(0.3),
            child: const Center(
              child: LoadingIndicator(),
            ),
          ),
      ],
    );
  }

  void _showDeleteConfirmationDialog(Map<String, dynamic> answerData) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Xác nhận xóa câu trả lời'),
          content: const Text('Bạn có chắc chắn muốn xóa câu trả lời này?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteAnswerFromFirebase(answerData);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                textStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              child: const Text('Xóa'),
            ),
          ],
        );
      },
    );
  }

  void _deleteAnswerFromFirebase(Map<String, dynamic> answerData) {
    FirebaseFirestore.instance.collection('questions').doc(question.id).update({
      'answers': FieldValue.arrayRemove([answerData])
    }).then((_) {
      print('Answer deleted from Firestore');
      _loadAnswers();
    }).catchError((error) {
      print('Failed to delete answer: $error');
    });
  }

  Future<void> _saveAnswerToFirebase(String answer, String? imageUrl) async {
    try {
      await FirebaseFirestore.instance
          .collection('questions')
          .doc(question.id)
          .update({
        'answers': FieldValue.arrayUnion([
          {
            'answer': answer,
            'imageUrl': imageUrl,
            'userId': FirebaseAuth.instance.currentUser!.uid,
            'timestamp': DateTime.now(),
          }
        ])
      });
    } catch (e) {
      debugPrint('Error saving answer: $e');
    }
  }

  void _showFullImage(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(10),
          child: GestureDetector(
            onTap: () => Navigator.pop(context), // Đóng khi bấm vào ảnh
            child: InteractiveViewer(
              panEnabled: true,
              minScale: 0.5,
              maxScale: 4.0,
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
              ),
            ),
          ),
        );
      },
    );
  }
}
