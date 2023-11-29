// ignore_for_file: use_build_context_synchronously

import 'package:assist_health/models/user/user_bmi.dart';
import 'package:assist_health/models/user/user_profile.dart';
import 'package:assist_health/others/methods.dart';
import 'package:assist_health/others/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  double _bmi = 0.0;
  String _bmiStatus = '';
  String _bmiAdvice = '';

  DateTime? _selectedDate;
  bool _heightError = false;
  bool _weightError = false;

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
        .doc(widget.userProfile.idDoc)
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
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Chỉ số BMI',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      _showBottomSheet(context, -1);
                    },
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: _bmiDataList.length,
              itemBuilder: (context, index) {
                final bmiData = _bmiDataList[index];
                return Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                  ),
                  margin:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey,
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.circular(10.0),
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
                                  color: Themes.textClr,
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
                );
              },
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
            ),
            color: Colors.white,
            child: Column(
              children: [
                const SizedBox(
                  height: 20,
                ),
                const Text(
                  'Chỉ số BMI',
                  style: TextStyle(
                    fontSize: 20,
                    color: Themes.primaryColor,
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
                                      color: Themes.iconClr,
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
                  color: Themes.buttonClr,
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
                          vertical: 10, horizontal: 30),
                      child: Text(
                        btnText.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
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
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã xảy ra lỗi khi xóa.'),
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
        const SnackBar(content: Text('Dữ liệu đã được cập nhật thành công.')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã xảy ra lỗi khi cập nhật dữ liệu.')),
      );
    }
  }

  _calculateBMI() {
    double weight = double.tryParse(_weightController.text) ?? 0.0;
    double height = double.tryParse(_heightController.text) ?? 0.0;
    if (weight > 0 && height > 0) {
      double bmiValue = weight / ((height / 100) * (height / 100));
      setState(() {
        _bmi = bmiValue;
        switch (_bmi) {
          case < 16:
            _bmiStatus = 'Gầy độ III';
            _bmiAdvice =
                'Bạn cần phải áp dụng một chế độ dinh dưỡng tốt nhất để có thể tăng cân, đảm bảo sức khỏe hoặc đi khám tại CSYT gần nhất.';
            break;
          case >= 16 && < 17:
            _bmiStatus = 'Gầy độ II';
            _bmiAdvice =
                'Bạn nên thêm một số thực phẩm dinh dưỡng để cải thiện trạng thái dinh dưỡng hoặc đi khám tại CSYT gần nhất.';
            break;
          case >= 17 && < 18.5:
            _bmiStatus = 'Gầy độ I';
            _bmiAdvice =
                'Bạn hãy cân nhắc bổ sung thêm dầu và thức ăn giàu năng lượng để tăng cường cân nặng hoặc đi khám tại CSYT gần nhất.';
            break;
          case >= 18.5 && < 25:
            _bmiStatus = 'Chỉ số BMI bình thường';
            _bmiAdvice = 'Bạn có một cơ thể tốt và tương đối khỏe mạnh.';
            break;
          case >= 25 && < 30:
            _bmiStatus = 'Thừa cân';
            _bmiAdvice =
                'Bạn cần phải điều chỉnh chế độ ăn hợp lí, theo dõi thường xuyên hoặc đi khám tại CSYT gần nhất.';
            break;
          case >= 30 && < 35:
            _bmiStatus = 'Béo phì độ I';
            _bmiAdvice =
                'Bạn hãy tập thể dục đều đặn và giảm lượng calo ăn uống để giảm cân hoặc đi khám tại CSYT gần nhất.';
            break;
          case >= 35 && < 40:
            _bmiStatus = 'Béo phì độ II';
            _bmiAdvice =
                'Bạn cần sự tư vấn từ chuyên gia dinh dưỡng để xây dựng chế độ ăn khoa học và thực hiện đều đặn.';
            break;
          default:
            _bmiStatus = 'Béo phì độ III';
            _bmiAdvice =
                'Bạn cần liên hệ với bác sĩ để có kế hoạch giảm cân và theo dõi sức khỏe toàn diện.';
            break;
        }
      });
      return bmiValue;
    }
    return 0;
  }
}
