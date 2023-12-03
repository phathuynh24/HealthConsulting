// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:assist_health/models/user/user_profile.dart';
import 'package:assist_health/models/user/user_temperature.dart';
import 'package:assist_health/others/methods.dart';
import 'package:assist_health/others/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// ignore: must_be_immutable
class HealthTemperatureScreen extends StatefulWidget {
  UserProfile userProfile;

  HealthTemperatureScreen({super.key, required this.userProfile});

  @override
  State<HealthTemperatureScreen> createState() =>
      _HealthTemperatureScreenState();
}

class _HealthTemperatureScreenState extends State<HealthTemperatureScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late String _uid;
  late DocumentReference _temperatureDocRef;

  List<UserTemperature> _temperatureDataList = [];

  final TextEditingController _temperatureController = TextEditingController();
  TextEditingController _dateController = TextEditingController();
  String _time = DateFormat("HH:mm").format(DateTime.now()).toString();

  DateTime? _selectedDate;
  bool _temperatureError = false;

  @override
  void initState() {
    super.initState();
    _uid = _auth.currentUser!.uid;
    _dateController = TextEditingController(
        text: DateFormat('dd/MM/yyyy').format(DateTime.now()));
    _temperatureDocRef = _firestore
        .collection('users')
        .doc(_uid)
        .collection('health_profiles')
        .doc(widget.userProfile.idDoc)
        .collection('health_metrics')
        .doc('temperature');
    _loadDataFromFirestore();
  }

  @override
  void dispose() {
    _temperatureController.dispose();
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
                    'Theo dỏi nhiệt độ',
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
              itemCount: _temperatureDataList.length,
              itemBuilder: (context, index) {
                final temperatureData = _temperatureDataList[index];
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
                              '${temperatureData.temperature} °C',
                              style: const TextStyle(
                                  color: Themes.textClr,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            temperatureData.date,
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
                      'Đo lúc ${temperatureData.time}',
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
      _dateController.text = _temperatureDataList[index].date;
      _time = _temperatureDataList[index].time;
      _temperatureController.text = _temperatureDataList[index].temperature;
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
                  'Theo dỏi nhiệt độ',
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
                                  borderRadius: BorderRadius.circular(12),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Giờ đo',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      Container(
                        height: 48,
                        margin: const EdgeInsets.only(top: 8.0),
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey, width: 1.0),
                            borderRadius: BorderRadius.circular(12)),
                        child: Row(
                          children: [
                            const SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: TextFormField(
                                readOnly: true,
                                autofocus: false,
                                cursorColor: Colors.grey,
                                decoration: InputDecoration(
                                  hintText: _time,
                                  focusedBorder: const UnderlineInputBorder(
                                      borderSide: BorderSide.none),
                                  enabledBorder: const UnderlineInputBorder(
                                      borderSide: BorderSide.none),
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                _getTimeFromUser();
                              },
                              icon: const Icon(
                                Icons.access_time_rounded,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
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
                        'Nhiệt độ (°C)',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      TextField(
                        controller: _temperatureController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(12.0)),
                          ),
                          hintText: "Nhập nhiệt độ hiện tại",
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 12),
                          errorText: _temperatureError
                              ? 'Vui lòng nhập giá trị lớn hơn 0'
                              : null,
                        ),
                        maxLines: 1,
                        onChanged: (value) {
                          setState(() {
                            if (value == '0') {
                              _temperatureController.text = '';
                            }
                            _temperatureError =
                                _temperatureController.text.isEmpty;
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
      firstDate: DateTime(2022),
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
      _temperatureError = _temperatureController.text.isEmpty;
    });
    if (!_temperatureError) return true;
    return false;
  }

  _loadDataFromFirestore() async {
    List<UserTemperature> temperatureDataList =
        await getTemperatureDataUser(_uid, widget.userProfile.idDoc);
    temperatureDataList.sort((a, b) {
      int dateComparison = b.date.compareTo(a.date);
      if (dateComparison != 0) {
        return dateComparison;
      } else {
        return b.time.compareTo(a.time);
      }
    });
    setState(() {
      _temperatureDataList = temperatureDataList;
    });
  }

  _saveDataToFirestore() {
    if (_validateInputs()) {
      String date = _dateController.text;
      String temperature = _temperatureController.text;
      String time = _time;

      _temperatureDocRef.set({
        'data': FieldValue.arrayUnion([
          {
            'date': date,
            'temperature': temperature,
            'time': time,
          }
        ])
      }, SetOptions(merge: true));

      _temperatureController.clear();

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
      await _temperatureDocRef.update({
        'data': FieldValue.arrayRemove([
          {
            'date': _temperatureDataList[index].date,
            'temperature': _temperatureDataList[index].temperature,
            'time': _temperatureDataList[index].time,
          }
        ])
      });

      setState(() {
        _temperatureDataList.removeAt(index);
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
    String temperature = _temperatureController.text;
    String time = _time;
    UserTemperature newUserTemperature =
        UserTemperature(temperature, date, time);
    setState(() {
      _temperatureDataList[index] = newUserTemperature;
    });

    List<Map<String, dynamic>> tempUserTemperature = _temperatureDataList
        .map((userTemperature) => {
              'date': userTemperature.date,
              'temperature': userTemperature.temperature,
              'time': userTemperature.time,
            })
        .toList();

    try {
      await _temperatureDocRef.update({'data': tempUserTemperature});

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

  _getTimeFromUser() async {
    TimeOfDay? pickedTime = await _showTimePicker();

    if (pickedTime != null) {
      String formattedTime = DateFormat('HH:mm').format(DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
        pickedTime.hour,
        pickedTime.minute,
      ));
      setState(() {
        _time = formattedTime;
      });
    } else {
      print("It's null or something is wrong");
    }
  }

  _showTimePicker() {
    TimeOfDay initialTime = TimeOfDay.now();

    if (_time.isNotEmpty) {
      List<int> timeParts = _time.split(':').map(int.parse).toList();
      initialTime = TimeOfDay(hour: timeParts[0], minute: timeParts[1]);
    }

    return showTimePicker(
      initialEntryMode: TimePickerEntryMode.input,
      context: context,
      initialTime: initialTime,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
  }
}
