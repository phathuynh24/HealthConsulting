// ignore_for_file: use_build_context_synchronously

import 'package:assist_health/models/user/user_weight.dart';
import 'package:assist_health/models/user/user_profile.dart';
import 'package:assist_health/others/methods.dart';
import 'package:assist_health/others/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

// ignore: must_be_immutable
class HealthWeightScreen extends StatefulWidget {
  UserProfile userProfile;

  HealthWeightScreen({super.key, required this.userProfile});

  @override
  State<HealthWeightScreen> createState() => _HealthWeightScreenState();
}

class _HealthWeightScreenState extends State<HealthWeightScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late String _uid;
  late DocumentReference _weightDocRef;

  List<UserWeight> _weightDataList = [];

  final TextEditingController _weightController = TextEditingController();
  TextEditingController _dateController = TextEditingController();

  DateTime? _selectedDate;
  bool _weightError = false;

  @override
  void initState() {
    super.initState();
    _uid = _auth.currentUser!.uid;
    _dateController = TextEditingController(
        text: DateFormat('dd/MM/yyyy').format(DateTime.now()));
    _weightDocRef = _firestore
        .collection('users')
        .doc(_uid)
        .collection('health_profiles')
        .doc(widget.userProfile.idDoc)
        .collection('health_metrics')
        .doc('weight');
    _loadDataFromFirestore();
  }

  @override
  void dispose() {
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
                    'Tăng trưởng cân nặng',
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
              itemCount: _weightDataList.length,
              itemBuilder: (context, index) {
                final weightData = _weightDataList[index];
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
                              '${weightData.weight} kg',
                              style: const TextStyle(
                                  color: Themes.textClr,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            weightData.date,
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
                          widget.userProfile.doB, weightData.date),
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
      _dateController.text = _weightDataList[index].date;
      _weightController.text = _weightDataList[index].weight;
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
                  'Tăng trưởng cân nặng',
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
      _weightError = _weightController.text.isEmpty;
    });
    if (!_weightError) return true;
    return false;
  }

  _loadDataFromFirestore() async {
    List<UserWeight> weightDataList =
        await getWeightDataUser(_uid, widget.userProfile.idDoc);
    weightDataList.sort((a, b) => b.date.compareTo(a.date));
    setState(() {
      _weightDataList = weightDataList;
    });
  }

  _saveDataToFirestore() {
    if (_validateInputs()) {
      String weight = _weightController.text;
      String date = _dateController.text;

      _weightDocRef.set({
        'data': FieldValue.arrayUnion([
          {
            'date': date,
            'weight': weight,
          }
        ])
      }, SetOptions(merge: true));

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
      await _weightDocRef.update({
        'data': FieldValue.arrayRemove([
          {
            'date': _weightDataList[index].date,
            'weight': _weightDataList[index].weight,
          }
        ])
      });

      setState(() {
        _weightDataList.removeAt(index);
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
    String weight = _weightController.text;
    UserWeight newUserWeight = UserWeight(weight, date);
    setState(() {
      _weightDataList[index] = newUserWeight;
    });

    List<Map<String, dynamic>> tempUserWeight = _weightDataList
        .map((userWeight) => {
              'date': userWeight.date,
              'weight': userWeight.weight,
            })
        .toList();

    try {
      await _weightDocRef.update({'data': tempUserWeight});

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
