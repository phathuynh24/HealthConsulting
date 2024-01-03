import 'package:assist_health/models/doctor/doctor_info.dart';
import 'package:assist_health/others/theme.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class DoctorInfoScreen extends StatefulWidget {
  @override
  _DoctorInfoScreenState createState() => _DoctorInfoScreenState();
}

class _DoctorInfoScreenState extends State<DoctorInfoScreen> {
  late User currentUser;
  DoctorInfo? _doctorInfo;


  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _serviceFeeController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _workplaceController = TextEditingController();
  final TextEditingController _emailController=TextEditingController();

  @override
  void initState() {
    super.initState();
    currentUser = FirebaseAuth.instance.currentUser!;
    loadDoctorInfo(currentUser.uid);
  }

  Future<void> loadDoctorInfo(String uid) async {
    try {
      // Lấy dữ liệu từ Firestore dựa trên UID của bác sĩ
      DocumentSnapshot doctorSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (doctorSnapshot.exists) {
        // Chuyển dữ liệu từ Firestore thành đối tượng DoctorInfo
        setState(() {
          _doctorInfo =
              DoctorInfo.fromMap(doctorSnapshot.data() as Map<String, dynamic>);
          _nameController.text = _doctorInfo?.name ?? '';
          _phoneController.text = _doctorInfo?.phone ?? '';
          _addressController.text=_doctorInfo?.address??'';
          _workplaceController.text=_doctorInfo?.workplace??'';
          _emailController.text=_doctorInfo?.email??'';
          _serviceFeeController.text = _doctorInfo?.serviceFee.toString() ?? '';
       
        });
      }
    } catch (e) {
      print('Error loading doctor info: $e');

    }
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: Text('Thông Tin Bác Sĩ',
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
          )
          )
      ),
      body: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Align(
                alignment: Alignment.center,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(
                    _doctorInfo?.imageURL 
                    ?? 'https://example.com/default_image.jpg',
                  ),
                ),
              ),            SizedBox(height: 16),
            // Hiển thị thông tin trong các TextField
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Họ và Tên'),
              enabled: false,
            ),
            TextField(
              controller: _workplaceController,
              decoration: InputDecoration(labelText: 'Nơi làm việc'),
              enabled: false,
            ),
            TextField(
              controller: _addressController,
              decoration: InputDecoration(labelText: 'Địa Chỉ'),
              enabled: false,
            ),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(labelText: 'Số Điện Thoại'),
              enabled: false,
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Địa Chỉ Email'),
              enabled: false,
            ),
            TextField(
              controller: _serviceFeeController,
              decoration: InputDecoration(labelText: 'Phí Dịch Vụ'),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            Align(
              alignment: Alignment.center,
              child:
            ElevatedButton(
              onPressed: () {
                // Xử lý khi nút "Lưu" được nhấn
                saveDoctorInfo();
              },
              child: Text('Lưu',
              style: TextStyle(fontSize: 18),),
              style: ElevatedButton.styleFrom(
                primary: Colors.blue,
                onPrimary: Colors.white, // Change the text color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // Adjust the border radius as needed
                  ),
                  padding: EdgeInsets.symmetric(vertical: 12,horizontal: 24),
              ),
            ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  Future<void> saveDoctorInfo() async {
    try {
      if (_doctorInfo != null) {
        // Cập nhật thông tin trong _doctorInfo từ các TextField
        _doctorInfo!.name = _nameController.text;
        _doctorInfo!.phone = _phoneController.text;
        _doctorInfo!.address=_addressController.text;
        _doctorInfo!.workplace=_workplaceController.text;
        _doctorInfo!.email=_workplaceController.text;
        _doctorInfo!.serviceFee = int.parse(_serviceFeeController.text);

        // Cập nhật thông tin trong Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .update(_doctorInfo!.toMap());

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Thông tin đã được cập nhật'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error saving doctor info: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã xảy ra lỗi khi lưu thông tin'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}