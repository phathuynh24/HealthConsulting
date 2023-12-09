// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'dart:ui';

import 'package:assist_health/models/user/user_profile.dart';
import 'package:assist_health/others/methods.dart';
import 'package:assist_health/others/theme.dart';
import 'package:assist_health/ui/user_screens/health_profile_add_edit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

class HealthProfileDetailScreen extends StatefulWidget {
  final UserProfile profile;

  const HealthProfileDetailScreen({super.key, required this.profile});

  @override
  State<HealthProfileDetailScreen> createState() =>
      _HealthProfileDetailScreenState();
}

class _HealthProfileDetailScreenState extends State<HealthProfileDetailScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  String? _uid;
  List<File> _selectedFiles = [];
  UserProfile? _currentProfile;

  @override
  void initState() {
    super.initState();
    _uid = _auth.currentUser!.uid;
    _currentProfile = widget.profile;
    loadDataFromFirebase();
  }

  @override
  void dispose() {
    super.dispose();
    for (File file in _selectedFiles) {
      file.deleteSync();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hồ sơ người thân'),
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
        actions: [
          if (_currentProfile!.idDoc != 'main_profile')
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                deleteDocumentProfile(_currentProfile!.idDoc);
              },
            ),
        ],
      ),
      body: Container(
        height: double.infinity,
        color: Colors.white,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  height: 180,
                  decoration: (_currentProfile!.image != '')
                      ? BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(_currentProfile!.image),
                            fit: BoxFit.cover,
                          ),
                        )
                      : null,
                  child: Stack(
                    children: [
                      Positioned(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(
                            sigmaX: 15,
                            sigmaY: 15,
                          ),
                          child: _currentProfile!.image.isNotEmpty
                              ? Container(
                                  color: Colors.transparent,
                                )
                              : Container(
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Themes.gradientDeepClr,
                                        Themes.gradientLightClr
                                      ],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ),
                                  ),
                                ),
                        ),
                      ),
                      // Ảnh nền
                      Positioned(
                        bottom: 20,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            width: 130,
                            height: 130,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: _currentProfile!.image.isNotEmpty
                                      ? Colors.black26
                                      : Colors.blue.shade700.withOpacity(0.8),
                                  spreadRadius: 2,
                                  blurRadius: 0,
                                  offset: const Offset(0, 2.5),
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: _currentProfile!.image.isNotEmpty
                                  ? Image.network(
                                      _currentProfile!.image,
                                      fit: BoxFit.cover,
                                      width: 130,
                                      height: 130,
                                    )
                                  : Container(
                                      width: 130,
                                      height: 130,
                                      decoration: const BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Themes.gradientDeepClr,
                                            Themes.gradientLightClr
                                          ],
                                          begin: Alignment.bottomCenter,
                                          end: Alignment.topCenter,
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          getAbbreviatedName(
                                              _currentProfile!.name),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 60,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Row(
                          children: [
                            Icon(
                              CupertinoIcons.folder_fill_badge_person_crop,
                              color: Colors.blue,
                              size: 30,
                            ),
                            SizedBox(width: 8.0),
                            Text(
                              'Thông tin cơ bản',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.blue),
                            ),
                          ],
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () async {
                            dynamic result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddOrEditProfileScreen(
                                  isEdit: true,
                                  profile: _currentProfile,
                                ),
                              ),
                            );
                            if (result != null && result is Map) {
                              bool isEdited = result['isEdited'];
                              UserProfile editedUserProfile = result['profile'];
                              if (isEdited) {
                                setState(() {
                                  _currentProfile = editedUserProfile;
                                });
                              }
                              ScaffoldMessenger.of(context)
                                  .hideCurrentSnackBar();
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(
                                content: Text('Điều chỉnh hồ sơ thành công!'),
                                backgroundColor: Colors.green,
                              ));
                            }
                          },
                          child: const Text(
                            'Điều chỉnh',
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 16.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Mã bệnh nhân',
                      style: TextStyle(
                          fontSize: 16,
                          color: Colors.blueGrey,
                          fontWeight: FontWeight.w400),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _currentProfile!.idProfile,
                      style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                          fontWeight: FontWeight.w400),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Họ và tên',
                      style: TextStyle(
                          fontSize: 16,
                          color: Colors.blueGrey,
                          fontWeight: FontWeight.w400),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _currentProfile!.name,
                      style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                          fontWeight: FontWeight.w400),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Số điện thoại',
                      style: TextStyle(
                          fontSize: 16,
                          color: Colors.blueGrey,
                          fontWeight: FontWeight.w400),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _currentProfile!.phone,
                      style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                          fontWeight: FontWeight.w400),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Ngày sinh',
                      style: TextStyle(
                          fontSize: 16,
                          color: Colors.blueGrey,
                          fontWeight: FontWeight.w400),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _currentProfile!.doB,
                      style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                          fontWeight: FontWeight.w400),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Giới tính',
                      style: TextStyle(
                          fontSize: 16,
                          color: Colors.blueGrey,
                          fontWeight: FontWeight.w400),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _currentProfile!.gender,
                      style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                          fontWeight: FontWeight.w400),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const Text(
                          'LỊCH SỬ XÉT NGHIỆM',
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.w500),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () {
                            _showBottomSheet(context);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              gradient: const LinearGradient(
                                colors: [
                                  Themes.gradientDeepClr,
                                  Themes.gradientLightClr
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                            ),
                            child: const Text(
                              'Cập nhật',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(
                        vertical: 10,
                      ),
                      child: GridView.builder(
                        padding: EdgeInsets.zero,
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _selectedFiles.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 6.0,
                          crossAxisSpacing: 6.0,
                          childAspectRatio: 1.0,
                        ),
                        itemBuilder: (context, index) {
                          File file = _selectedFiles[index];
                          String extension =
                              file.path.split('.').last.toLowerCase();
                          return GestureDetector(
                            onTap: () {
                              OpenFile.open(file.path);
                            },
                            child: Stack(
                              children: [
                                LayoutBuilder(builder: (BuildContext context,
                                    BoxConstraints constraints) {
                                  return Center(
                                    child: Container(
                                      height: constraints.maxWidth - 10,
                                      width: constraints.maxHeight - 10,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(6),
                                        color: Colors.grey,
                                      ),
                                      alignment: Alignment.center,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          if (extension == 'pdf')
                                            const Icon(Icons.picture_as_pdf,
                                                size: 50),
                                          if (extension == 'doc' ||
                                              extension == 'docx')
                                            const Icon(Icons.description,
                                                size: 50),
                                          if (extension == 'mp4')
                                            const Icon(Icons.play_circle_filled,
                                                size: 50),
                                          if (extension == 'png' ||
                                              extension == 'jpg' ||
                                              extension == 'jpeg')
                                            SizedBox(
                                              height: constraints.maxWidth - 10,
                                              width: constraints.maxHeight - 10,
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                                child: Image.file(
                                                  file,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        File file = _selectedFiles[index];
                                        // Xóa tệp cục bộ
                                        file.deleteSync();
                                        // Xóa tệp khỏi danh sách
                                        _selectedFiles.removeAt(index);
                                        // Xóa file trên firebase
                                        deleteFileFromFirestore(index);
                                      });
                                    },
                                    child: const CircleAvatar(
                                      backgroundColor: Themes.iconClr,
                                      radius: 12,
                                      child: Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 15,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo),
              title: const Text('Chọn file từ thư viện'),
              onTap: () {
                Navigator.pop(context);
                pickMultipleFile();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera),
              title: const Text('Chụp ảnh'),
              onTap: () {
                Navigator.pop(context);
                captureImage();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> pickMultipleFile() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['png', 'jpg', 'jpeg', 'mp4', 'doc', 'docx', 'pdf'],
    );
    if (result != null) {
      setState(() {
        _selectedFiles.addAll(result.paths.map((path) => File(path!)));
      });
      for (var file in result.paths.map((path) => File(path!))) {
        await uploadFile(file);
      }
    }
  }

  Future<void> captureImage() async {
    final imagePicker = ImagePicker();
    final pickedFile = await imagePicker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _selectedFiles.add(File(pickedFile.path));
      });
      // Chuyển đổi XFile thành File
      File pickedFileAsFile = File(pickedFile.path);
      await uploadFile(pickedFileAsFile);
    }
  }

  Future<void> uploadFile(File file) async {
    try {
      // Tạo tham chiếu đến Firebase Storage
      final storageRef = _storage.ref().child(
          'files/${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}');

      await storageRef.putFile(file);

      // Lấy đường dẫn tới file vừa tải lên
      String downloadURL = await storageRef.getDownloadURL();

      // Lưu downloadURL vào collection files
      await _firestore
          .collection('users')
          .doc(_uid)
          .collection('health_profiles')
          .doc(widget.profile.idDoc)
          .collection('fileURLs')
          .doc('data')
          .set({
        'data': FieldValue.arrayUnion([downloadURL]),
      }, SetOptions(merge: true));
    } catch (error) {}
  }

  Future<List<String>> getFileURLsFromStorage() async {
    List<String> urls = [];

    DocumentSnapshot snapshot = await _firestore
        .collection('users')
        .doc(_uid)
        .collection('health_profiles')
        .doc(widget.profile.idDoc)
        .collection('fileURLs')
        .doc('data')
        .get();

    if (snapshot.exists) {
      Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;
      if (data != null) {
        List<dynamic>? urlList = data['data'];
        if (urlList != null) {
          urls = List<String>.from(urlList);
        }
      }
    }

    return urls;
  }

  loadDataFromFirebase() async {
    List<String> fileURLs = await getFileURLsFromStorage();
    List<File> files = [];

    for (String fileURL in fileURLs) {
      // Tạo một đối tượng File từ URL
      File file = await getFileFromURL(fileURL);
      // Thêm file đã tải về vào danh sách
      files.add(file);
    }

    // Cập nhật danh sách các file đã tải về vào biến thành viên
    setState(() {
      _selectedFiles = files;
    });
  }

  Future<File> getFileFromURL(String url) async {
    String extension = getExtensionFromURL(url);
    // Sử dụng package http để tải file từ URL
    var response = await http.get(Uri.parse(url));
    var tempDir = await getTemporaryDirectory();
    File file = File(
        '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.$extension');

    await file.writeAsBytes(response.bodyBytes);
    return file;
  }

  String getExtensionFromURL(String url) {
    String start = 'files%';
    String end = '?';
    String extension;
    int startIndex = url.indexOf(start);

    if (startIndex != -1) {
      String remaining = url.substring(startIndex + start.length);
      int endIndex = remaining.indexOf(end);

      if (endIndex != -1) {
        String fileName = remaining.substring(0, endIndex);
        extension = fileName.split('.').last;
        return extension;
      }
    }

    return '';
  }

  void deleteFileFromFirestore(int index) async {
    final DocumentReference fileURLsDocument = _firestore
        .collection('users')
        .doc(_uid)
        .collection('health_profiles')
        .doc(widget.profile.idDoc)
        .collection('fileURLs')
        .doc('data');

    final DocumentSnapshot documentSnapshot = await fileURLsDocument.get();
    if (documentSnapshot.exists) {
      final Map<String, dynamic> data =
          documentSnapshot.data() as Map<String, dynamic>;
      final List<dynamic> dataList = List.from(data['data'] ?? []);
      if (dataList.length > index) {
        //final String fileId = dataList[index]['fileId'];

        // Xóa phần tử trong Firestore
        dataList.removeAt(index);
        await fileURLsDocument.update({'data': dataList});

        // Xóa tệp từ Firebase Storage
        //final Reference storageRef = FirebaseStorage.instance.ref().child(fileId);
        //await storageRef.delete();
      }
    }
  }

  Future<void> deleteDocumentProfile(String documentName) async {
    final DocumentReference documentReference = _firestore
        .collection('users')
        .doc(_uid)
        .collection('health_profiles')
        .doc(documentName);

    // Hiển thị thông báo xác nhận xóa
    bool confirmDelete = await showDeleteConfirmation();

    if (confirmDelete) {
      // Quay lại trang trước đó tại đây
      Navigator.pop(context);
      // Hiển thị thông báo xóa thành công
      showDeleteSuccessSnackBar();
      await documentReference.delete();
    }
  }

  Future<bool> showDeleteConfirmation() async {
    bool confirmDelete = false;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xóa hồ sơ y tế'),
          content: const Text('Bạn có chắc chắn muốn xóa hồ sơ y tế này?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Bấm nút không
              },
              child: const Text('Không'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Bấm nút có
              },
              child: const Text('Có'),
            ),
          ],
        );
      },
    ).then((value) {
      confirmDelete = value ?? false;
    });

    return confirmDelete;
  }

  void showDeleteSuccessSnackBar() {
    const snackBar = SnackBar(
      content: Text('Xóa tài liệu thành công'),
      backgroundColor: Colors.green,
      duration: Duration(seconds: 2),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
