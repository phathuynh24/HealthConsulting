import 'dart:ui';

import 'package:assist_health/src/models/doctor/doctor_info.dart';
import 'package:assist_health/src/others/methods.dart';
import 'package:assist_health/src/others/theme.dart';
import 'package:assist_health/src/widgets/input_field.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class DoctorInfoScreen extends StatefulWidget {
  const DoctorInfoScreen({super.key});

  @override
  State<DoctorInfoScreen> createState() => _DoctorInfoScreenState();
}

class _DoctorInfoScreenState extends State<DoctorInfoScreen> {
  late User currentUser;
  DoctorInfo? _doctorInfo;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _serviceFeeController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _workplaceController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  bool _isLoading = false;
  String _endTime = "23:59";
  String _startTime = DateFormat("HH:mm").format(DateTime.now()).toString();

  @override
  void initState() {
    super.initState();
    currentUser = FirebaseAuth.instance.currentUser!;
    loadDoctorInfo(currentUser.uid);
  }

  Future<void> loadDoctorInfo(String uid) async {
    setState(() {
      _isLoading = true;
    });
    try {
      // Lấy dữ liệu từ Firestore dựa trên UID của bác sĩ
      DocumentSnapshot doctorSnapshot =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (doctorSnapshot.exists) {
        // Chuyển dữ liệu từ Firestore thành đối tượng DoctorInfo
        setState(() {
          _doctorInfo =
              DoctorInfo.fromMap(doctorSnapshot.data() as Map<String, dynamic>);
          _nameController.text = _doctorInfo?.name ?? '';
          _phoneController.text = _doctorInfo?.phone ?? '';
          _addressController.text = _doctorInfo?.address ?? '';
          _workplaceController.text = _doctorInfo?.workplace ?? '';
          _emailController.text = _doctorInfo?.email ?? '';
          _serviceFeeController.text = _doctorInfo?.serviceFee.toString() ?? '';
          _startTime = _doctorInfo!.startTime!;
          _endTime = _doctorInfo!.endTime!;
        });
      }
    } catch (e) {
      print('Error loading doctor info: $e');
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (!_isLoading)
          Scaffold(
            appBar: AppBar(
                foregroundColor: Colors.white,
                title: const Text(
                  'Thông Tin Bác Sĩ',
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
                ))),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        height: 180,
                        decoration: (_doctorInfo!.imageURL != '')
                            ? BoxDecoration(
                                image: DecorationImage(
                                  image: NetworkImage(_doctorInfo!.imageURL),
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
                                child: _doctorInfo!.imageURL.isNotEmpty
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
                                        color: _doctorInfo!.imageURL.isNotEmpty
                                            ? Colors.black26
                                            : Colors.blue.shade700
                                                .withOpacity(0.8),
                                        spreadRadius: 2,
                                        blurRadius: 0,
                                        offset: const Offset(0, 2.5),
                                      ),
                                    ],
                                  ),
                                  child: ClipOval(
                                    child: _doctorInfo!.imageURL.isNotEmpty
                                        ? Image.network(
                                            _doctorInfo!.imageURL,
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
                                                    _doctorInfo!.name),
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
                    const SizedBox(height: 16),
                    // Hiển thị thông tin trong các TextField
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Họ và tên'),
                      enabled: false,
                    ),
                    TextField(
                      controller: _workplaceController,
                      decoration:
                          const InputDecoration(labelText: 'Nơi làm việc'),
                      enabled: false,
                    ),
                    TextField(
                      controller: _addressController,
                      decoration: const InputDecoration(labelText: 'Địa Chỉ'),
                      maxLines: 2,
                      enabled: false,
                    ),
                    TextField(
                      controller: _phoneController,
                      decoration:
                          const InputDecoration(labelText: 'Số Điện Thoại'),
                      enabled: false,
                    ),
                    TextField(
                      controller: _emailController,
                      decoration:
                          const InputDecoration(labelText: 'Địa Chỉ Email'),
                      enabled: false,
                    ),
                    TextField(
                      controller: _serviceFeeController,
                      decoration:
                          const InputDecoration(labelText: 'Phí Dịch Vụ (VNĐ)'),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      keyboardType: TextInputType.number,
                    ),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                      margin: EdgeInsets.symmetric(vertical: 15),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.grey.withOpacity(0.1),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Thời gian làm việc',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: MyInputField(
                                  title: "Bắt đầu",
                                  hint: _startTime,
                                  widget: IconButton(
                                    onPressed: () {
                                      _getTimeFromUser(isStartTime: true);
                                    },
                                    icon: const Icon(
                                      Icons.access_time_rounded,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: MyInputField(
                                  title: "Kết thúc",
                                  hint: _endTime,
                                  widget: IconButton(
                                    onPressed: () {
                                      _getTimeFromUser(isStartTime: false);
                                    },
                                    icon: const Icon(
                                      Icons.access_time_rounded,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            bottomNavigationBar: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: ElevatedButton(
                onPressed: () {
                  // Xử lý khi nút "Lưu" được nhấn
                  saveDoctorInfo();
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.blue,
                  onPrimary: Colors.white, // Change the text color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        10), // Adjust the border radius as needed
                  ),
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                ),
                child: const Text(
                  'Lưu thông tin',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ),
        if (_isLoading)
          const Center(
            child: const CircularProgressIndicator(),
          )
      ],
    );
  }

  Future<void> saveDoctorInfo() async {
    try {
      if (_doctorInfo != null) {
        // Cập nhật thông tin trong _doctorInfo từ các TextField
        _doctorInfo!.name = _nameController.text;
        _doctorInfo!.phone = _phoneController.text;
        _doctorInfo!.address = _addressController.text;
        _doctorInfo!.workplace = _workplaceController.text;
        _doctorInfo!.email = _workplaceController.text;
        _doctorInfo!.serviceFee = int.parse(_serviceFeeController.text);
        _doctorInfo!.startTime = _startTime;
        _doctorInfo!.endTime = _endTime;

        // Cập nhật thông tin trong Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .update(_doctorInfo!.toMap());

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Thông tin đã được cập nhật'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error saving doctor info: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã xảy ra lỗi khi lưu thông tin'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  _getTimeFromUser({required bool isStartTime}) async {
    TimeOfDay? pickedTime = await _showTimePicker();

    if (pickedTime != null) {
      // ignore: use_build_context_synchronously
      String formattedTime = pickedTime.format(context);
      if (isStartTime) {
        setState(() {
          _startTime = formattedTime;
        });
      } else {
        setState(() {
          _endTime = formattedTime;
        });
      }
    } else {
      print("It's null or something is wrong");
    }
  }

  _showTimePicker() {
    return showTimePicker(
      initialEntryMode: TimePickerEntryMode.input,
      context: context,
      initialTime: TimeOfDay(
        hour: int.parse(_startTime.split(":")[0]),
        minute: int.parse(_startTime.split(":")[1].split(" ")[0]),
      ),
    );
  }
}
