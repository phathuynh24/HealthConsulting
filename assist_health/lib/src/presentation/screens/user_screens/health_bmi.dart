// ignore_for_file: use_build_context_synchronously

import 'package:assist_health/src/models/user/user_bmi.dart';
import 'package:assist_health/src/models/user/user_profile.dart';
import 'package:assist_health/src/others/methods.dart';
import 'package:assist_health/src/others/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

// ignore: must_be_immutable
class HealthBMIScreen extends StatefulWidget {
  UserProfile userProfile;

  HealthBMIScreen({super.key, required this.userProfile});

  @override
  State<HealthBMIScreen> createState() => _HealthBMIScreenState();
}

class _HealthBMIScreenState extends State<HealthBMIScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late String _uid;
  late DocumentReference _bmiDocRef;

  List<UserBMI> _bmiDataList = [];

  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  TextEditingController _dateController = TextEditingController();

  DateTime? _selectedDate;
  bool _heightError = false;
  bool _weightError = false;

  List<bool> _isShowList = [];

  @override
  void initState() {
    super.initState();
    _uid = _auth.currentUser!.uid;
    _dateController = TextEditingController(
        text: DateFormat('dd/MM/yyyy').format(DateTime.now()));
    _bmiDocRef = _firestore
        .collection('users')
        .doc(_uid)
        .collection('health_profiles')
        .doc('main_profile')
        .collection('health_metrics')
        .doc('bmi');
    _loadDataFromFirestore();
  }

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Chỉ số BMI',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      fontSize: 18,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      _showBottomSheet(context, -1);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 5),
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Themes.gradientDeepClr,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Divider(
            thickness: 0.9,
            color: Colors.grey.shade200,
            height: 0,
          ),
          Expanded(
            child: Container(
              color: Colors.grey.shade100,
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: _bmiDataList.length,
                itemBuilder: (context, index) {
                  final bmiData = _bmiDataList[index];
                  _isShowList.add(false);
                  return Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 15),
                    decoration: BoxDecoration(
                      color: Colors.blueGrey.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.only(top: 6),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 5,
                                spreadRadius: 2,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ListTile(
                            title: Container(
                              margin: const EdgeInsets.only(
                                bottom: 8,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      color: Colors.amber,
                                    ),
                                    child: Text(
                                      bmiData.bmi,
                                      style: const TextStyle(
                                          color: Themes.gradientDeepClr,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    bmiData.date,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            subtitle: Text(
                              calculateBirthdayToSelectedDate(
                                  widget.userProfile.doB, bmiData.date),
                              style: const TextStyle(fontSize: 16),
                            ),
                            trailing: PopupMenuButton(
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Text('Sửa'),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Text('Xóa'),
                                ),
                              ],
                              onSelected: (value) {
                                if (value == 'edit') {
                                  _handleUpdate(index);
                                } else if (value == 'delete') {
                                  _handleDelete(index);
                                }
                              },
                            ),
                          ),
                        ),
                        Visibility(
                          visible: _isShowList[index],
                          child: Container(
                            margin: const EdgeInsets.only(
                                left: 14, right: 14, top: 15),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              color: _getBMIStatusColor(
                                  double.tryParse(bmiData.bmi)!),
                            ),
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    _getBMIStatus(
                                        double.tryParse(bmiData.bmi)!),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Text(
                                    _getBMIAdvice(
                                        double.tryParse(bmiData.bmi)!),
                                    style: const TextStyle(
                                      color: Colors.white,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _isShowList[index] = !_isShowList[index];
                            });
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.only(bottom: 8, top: 8),
                                child: Text(
                                  'Xem chi tiết',
                                  style: TextStyle(
                                    color:
                                        Themes.gradientDeepClr.withOpacity(0.7),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              Icon(
                                (_isShowList[index])
                                    ? FontAwesomeIcons.angleDown
                                    : FontAwesomeIcons.angleUp,
                                size: 14,
                                color: Themes.gradientDeepClr.withOpacity(0.7),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  _showBottomSheet(BuildContext context, int index) {
    if (index != -1) {
      _dateController.text = _bmiDataList[index].date;
      _heightController.text = _bmiDataList[index].height;
      _weightController.text = _bmiDataList[index].weight;
    }

    String btnText = (index != -1) ? 'Cập nhật chỉ số' : 'Thêm chỉ số';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              left: 8,
              right: 8,
            ),
            decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                )),
            child: Column(
              children: [
                const SizedBox(
                  height: 20,
                ),
                const Text(
                  'Chỉ số BMI',
                  style: TextStyle(
                    fontSize: 20,
                    color: Themes.gradientDeepClr,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                const Text(
                  'Nhập chỉ số hiện tại của bạn',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 15,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Ngày',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _dateController,
                              readOnly: true,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 12),
                              ),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    _selectDate(context);
                                  },
                                  splashColor: Themes.highlightClr,
                                  child: const Padding(
                                    padding: EdgeInsets.all(5.0),
                                    child: Icon(
                                      Icons.calendar_month_sharp,
                                      size: 40,
                                      color: Themes.gradientDeepClr,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 15,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Chiều cao (cm)',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      TextField(
                        controller: _heightController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          hintText: "Nhập chiều cao (cm)",
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 12),
                          errorText: _heightError
                              ? 'Vui lòng nhập giá trị lớn hơn 0'
                              : null,
                        ),
                        maxLines: 1,
                        onChanged: (value) {
                          setState(() {
                            if (value == '0') {
                              _heightController.text = '';
                            }
                            _heightError = _heightController.text.isEmpty;
                          });
                        },
                      )
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 15,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Cân nặng (kg)',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      TextField(
                        controller: _weightController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          hintText: "Nhập cân nặng (kg)",
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 12),
                          errorText: _weightError
                              ? 'Vui lòng nhập giá trị lớn hơn 0'
                              : null,
                        ),
                        maxLines: 1,
                        onChanged: (value) {
                          setState(() {
                            if (value == '0') {
                              _weightController.text = '';
                            }
                            _weightError = _weightController.text.isEmpty;
                          });
                        },
                      )
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Material(
                  color: Themes.gradientDeepClr,
                  borderRadius: BorderRadius.circular(5),
                  child: InkWell(
                    onTap: () {
                      if (index == -1) {
                        _saveDataToFirestore();
                      } else {
                        _updateDataInFirestore(index);
                      }
                      _loadDataFromFirestore();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 40),
                      child: Text(
                        btnText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  _validateInputs() {
    setState(() {
      _heightError = _heightController.text.isEmpty;
      _weightError = _weightController.text.isEmpty;
    });
    if (!_heightError && !_weightError) return true;
    return false;
  }

  _loadDataFromFirestore() async {
    List<UserBMI> bmiDataList =
        await getBMIDataUser(_uid, widget.userProfile.idDoc);
    bmiDataList.sort((a, b) => b.date.compareTo(a.date));
    setState(() {
      _bmiDataList = bmiDataList;
    });
  }

  _saveDataToFirestore() {
    if (_validateInputs()) {
      String date = _dateController.text;
      String height = _heightController.text;
      String weight = _weightController.text;
      String bmi = _calculateBMI().toStringAsFixed(1);

      _bmiDocRef.set({
        'data': FieldValue.arrayUnion([
          {
            'date': date,
            'height': height,
            'weight': weight,
            'bmi': bmi,
          }
        ])
      }, SetOptions(merge: true));

      _heightController.clear();
      _weightController.clear();

      Navigator.pop(context);
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã lưu thông tin.'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  _handleDelete(int index) async {
    try {
      await _bmiDocRef.update({
        'data': FieldValue.arrayRemove([
          {
            'date': _bmiDataList[index].date,
            'height': _bmiDataList[index].height,
            'weight': _bmiDataList[index].weight,
            'bmi': _bmiDataList[index].bmi,
          }
        ])
      });

      setState(() {
        _bmiDataList.removeAt(index);
      });

      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã xóa thành công.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã xảy ra lỗi khi xóa.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  _handleUpdate(int index) {
    _showBottomSheet(context, index);
  }

  _updateDataInFirestore(int index) async {
    String date = _dateController.text;
    String height = _heightController.text;
    String weight = _weightController.text;
    String bmi = _calculateBMI().toStringAsFixed(1);
    UserBMI newUserBMI = UserBMI(date, height, weight, bmi);
    setState(() {
      _bmiDataList[index] = newUserBMI;
    });

    List<Map<String, dynamic>> tempUserBMI = _bmiDataList
        .map((userHeight) => {
              'date': userHeight.date,
              'height': userHeight.height,
              'weight': userHeight.height,
              'bmi': userHeight.height,
            })
        .toList();

    try {
      await _bmiDocRef.update({'data': tempUserBMI});

      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dữ liệu đã được cập nhật thành công.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã xảy ra lỗi khi cập nhật dữ liệu.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  _calculateBMI() {
    double weight = double.tryParse(_weightController.text) ?? 0.0;
    double height = double.tryParse(_heightController.text) ?? 0.0;
    if (weight > 0 && height > 0) {
      double bmiValue = weight / ((height / 100) * (height / 100));

      return bmiValue;
    }
    return 0;
  }

  _getBMIStatus(double bmi) {
    switch (bmi) {
      case < 16:
        return 'Gầy độ III';
      case >= 16 && < 17:
        return 'Gầy độ II';
      case >= 17 && < 18.5:
        return 'Gầy độ I';
      case >= 18.5 && < 25:
        return 'Chỉ số BMI bình thường';
      case >= 25 && < 30:
        return 'Thừa cân';
      case >= 30 && < 35:
        return 'Béo phì độ I';
      case >= 35 && < 40:
        return 'Béo phì độ II';
      default:
        return 'Béo phì độ III';
    }
  }

  _getBMIAdvice(double bmi) {
    switch (bmi) {
      case < 16:
        return 'Bạn cần phải áp dụng một chế độ dinh dưỡng tốt nhất để có thể tăng cân, đảm bảo sức khỏe hoặc đi khám tại CSYT gần nhất.';
      case >= 16 && < 17:
        return 'Bạn nên thêm một số thực phẩm dinh dưỡng để cải thiện trạng thái dinh dưỡng hoặc đi khám tại CSYT gần nhất.';
      case >= 17 && < 18.5:
        return 'Bạn hãy cân nhắc bổ sung thêm dầu và thức ăn giàu năng lượng để tăng cường cân nặng hoặc đi khám tại CSYT gần nhất.';
      case >= 18.5 && < 25:
        return 'Bạn có một cơ thể tốt và tương đối khỏe mạnh.';
      case >= 25 && < 30:
        return 'Bạn cần phải điều chỉnh chế độ ăn hợp lí, theo dõi thường xuyên hoặc đi khám tại CSYT gần nhất.';
      case >= 30 && < 35:
        return 'Bạn hãy tập thể dục đều đặn và giảm lượng calo ăn uống để giảm cân hoặc đi khám tại CSYT gần nhất.';
      case >= 35 && < 40:
        return 'Bạn cần sự tư vấn từ chuyên gia dinh dưỡng để xây dựng chế độ ăn khoa học và thực hiện đều đặn.';
      default:
        return 'Bạn cần liên hệ với bác sĩ để có kế hoạch giảm cân và theo dõi sức khỏe toàn diện.';
    }
  }

  Color _getBMIStatusColor(double bmi) {
    if (bmi < 16) {
      return Colors.red; // Màu đỏ cho Gầy độ III
    } else if (bmi >= 16 && bmi < 17) {
      return Colors.orange; // Màu cam cho Gầy độ II
    } else if (bmi >= 17 && bmi < 18.5) {
      return Colors.yellow.shade700; // Màu vàng cho Gầy độ I
    } else if (bmi >= 18.5 && bmi < 25) {
      return Colors.green; // Màu xanh lá cho BMI bình thường
    } else if (bmi >= 25 && bmi < 30) {
      return Colors.blue; // Màu xanh dương cho Thừa cân
    } else if (bmi >= 30 && bmi < 35) {
      return Colors.purple; // Màu tím cho Béo phì độ I
    } else if (bmi >= 35 && bmi < 40) {
      return Colors.deepPurple; // Màu tím đậm cho Béo phì độ II
    } else {
      return Colors.black; // Màu đen cho Béo phì độ III
    }
  }
}
