// ignore_for_file: use_build_context_synchronously

import 'package:assist_health/models/user/user_height.dart';
import 'package:assist_health/models/user/user_profile.dart';
import 'package:assist_health/others/methods.dart';
import 'package:assist_health/others/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

// ignore: must_be_immutable
class HealthHeightScreen extends StatefulWidget {
  UserProfile userProfile;

  HealthHeightScreen({super.key, required this.userProfile});

  @override
  State<HealthHeightScreen> createState() => _HealthHeightScreenState();
}

class _HealthHeightScreenState extends State<HealthHeightScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late String _uid;
  late DocumentReference _heightDocRef;

  List<UserHeight> _heightDataList = [];

  final TextEditingController _heightController = TextEditingController();
  TextEditingController _dateController = TextEditingController();

  DateTime? _selectedDate;
  bool _heightError = false;

  @override
  void initState() {
    super.initState();
    _uid = _auth.currentUser!.uid;
    _dateController = TextEditingController(
        text: DateFormat('dd/MM/yyyy').format(DateTime.now()));
    _heightDocRef = _firestore
        .collection('users')
        .doc(_uid)
        .collection('health_profiles')
        .doc(widget.userProfile.idDoc)
        .collection('health_metrics')
        .doc('height');
    _loadDataFromFirestore();
  }

  @override
  void dispose() {
    _heightController.dispose();
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
                    'Tăng trưởng chiều cao',
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
              itemCount: _heightDataList.length,
              itemBuilder: (context, index) {
                final heightData = _heightDataList[index];
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
                              '${heightData.height} cm',
                              style: const TextStyle(
                                  color: Themes.textClr,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            heightData.date,
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
                          widget.userProfile.doB, heightData.date),
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
      _dateController.text = _heightDataList[index].date;
      _heightController.text = _heightDataList[index].height;
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
                  'Tăng trưởng chiều cao',
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
    });
    if (!_heightError) return true;
    return false;
  }

  _loadDataFromFirestore() async {
    List<UserHeight> heightDataList =
        await getHeightDataUser(_uid, widget.userProfile.idDoc);
    heightDataList.sort((a, b) => b.date.compareTo(a.date));
    setState(() {
      _heightDataList = heightDataList;
    });
  }

  _saveDataToFirestore() {
    if (_validateInputs()) {
      String height = _heightController.text;
      String date = _dateController.text;

      _heightDocRef.set({
        'data': FieldValue.arrayUnion([
          {
            'date': date,
            'height': height,
          }
        ])
      }, SetOptions(merge: true));

      _heightController.clear();

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
      await _heightDocRef.update({
        'data': FieldValue.arrayRemove([
          {
            'date': _heightDataList[index].date,
            'height': _heightDataList[index].height,
          }
        ])
      });

      setState(() {
        _heightDataList.removeAt(index);
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
    UserHeight newUserHeight = UserHeight(height, date);
    setState(() {
      _heightDataList[index] = newUserHeight;
    });

    List<Map<String, dynamic>> tempUserHeight = _heightDataList
        .map((userHeight) => {
              'date': userHeight.date,
              'height': userHeight.height,
            })
        .toList();

    try {
      await _heightDocRef.update({'data': tempUserHeight});

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
}
