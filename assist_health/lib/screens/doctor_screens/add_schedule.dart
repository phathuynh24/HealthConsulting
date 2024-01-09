// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:assist_health/models/doctor/doctor_service.dart';
import 'package:assist_health/others/methods.dart';
import 'package:assist_health/others/theme.dart';
import 'package:assist_health/screens/widgets/input_field.dart';

class AddSchedulePage extends StatefulWidget {
  const AddSchedulePage({super.key});

  @override
  State<AddSchedulePage> createState() => _AddSchedulePageState();
}

class _AddSchedulePageState extends State<AddSchedulePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isInitialized = true;

  @override
  initState() {
    super.initState();
    // _initialize().then((_) {
    //   setState(() {
    //     _isInitialized = true;
    //   });
    // });
  }

  String? _uid;
  DateTime _selectedDate = DateTime.now();
  String _endTime = "9:30";
  String _startTime = DateFormat("HH:mm").format(DateTime.now()).toString();

  final List<int> _options = [];
  List<bool> _isSelectedOptions = [];

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Scaffold(
      backgroundColor: Themes.backgroundClr,
      appBar: AppBar(
        title: const Text('Thêm lịch khám'),
        centerTitle: true,
        backgroundColor: Themes.hearderClr,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              MyInputField(
                title: "Ngày làm việc",
                hint: DateFormat('dd/MM/yyyy').format(_selectedDate),
                widget: IconButton(
                  icon: const Icon(
                    Icons.calendar_today_outlined,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    _getDateFromUser();
                  },
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: MyInputField(
                      title: "Thời gian bắt đầu",
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
                      title: "Thời gian kết thúc",
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
              const SizedBox(height: 16),
              _checkboxGroup(),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Themes.buttonClr,
                ),
                onPressed: () {
                  if (_isFormValid()) {
                    _saveScheduleToFirebase();
                    Navigator.of(context).pop();
                  } else {
                    // Hiển thị thông báo hoặc xử lý khi biểu mẫu không hợp lệ
                  }
                },
                child: const Text('Lưu'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _initialize() async {
    String? uid = _auth.currentUser!.uid;
    List<DoctorService> services = await getServicesDoctor(uid);
    setState(() {
      _uid = uid;
    });
    _addTime(_options, services[0].time);
    _isSelectedOptions = List.filled(_options.length, false);
  }

  _getDateFromUser() async {
    DateTime? pickerDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2123),
    );

    if (pickerDate != null) {
      setState(() {
        _selectedDate = pickerDate;
      });
    } else {
      print("It's null or something is wrong");
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

  _checkboxGroup() {
    return Container(
      margin: const EdgeInsets.symmetric(
        vertical: 20,
      ),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _options.length,
        itemBuilder: (_, index) {
          if (index == 0) {
            return Column(
              children: [
                Row(
                  children: [
                    Checkbox(
                      value: _isSelectedOptions[index],
                      onChanged: (value) {
                        setState(() {
                          _isSelectedOptions[index] = value!;
                          _isSelectedOptions =
                              List.filled(_options.length, value);
                        });
                      },
                    ),
                    const Text("Chọn tất cả"),
                  ],
                ),
                const Divider(
                  color: Colors.grey,
                  height: 20,
                  thickness: 1,
                  endIndent: 0,
                ),
              ],
            );
          } else {
            return Row(
              children: [
                Checkbox(
                  value: _isSelectedOptions[index],
                  onChanged: (value) {
                    setState(() {
                      _isSelectedOptions[index] = value!;
                      _isSelectedOptions[0] = _isSelectedOptions
                          .getRange(1, _isSelectedOptions.length)
                          .every((element) => element == true);
                    });
                  },
                ),
                Text("${_options[index]} phút"),
              ],
            );
          }
        },
      ),
    );
  }

  _isFormValid() {
    if (!_isSelectedOptions.every((element) => element == false)) {
      return true;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hãy điền đủ thông tin!'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
      return false;
    }
  }

  _saveScheduleToFirebase() async {
    final schedulesCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(_uid)
        .collection('schedule');

    String date = DateFormat('dd-MM-yyyy').format(_selectedDate);
    String startTime = _convert12hTo24h(_startTime);
    String endTime = _convert12hTo24h(_endTime);
    List<String> calcedTime = [];
    List<int> selectedOptions = _selectedOptions();

    // Tạo một document mới với ID là ngày được chọn
    final newDocument = schedulesCollection.doc(date);

    for (int i = 0; i < selectedOptions.length; i++) {
      calcedTime.clear();
      calcedTime = _calcTime(_startTime, _endTime, selectedOptions[i], 0);

      // Tạo một map chứa thông tin lịch khám
      final scheduleData = {
        'date': date,
        'time_line': {
          '$startTime - $endTime': {
            '${selectedOptions[i]} minutes': calcedTime,
          },
        },
      };

      // Lưu thông tin lịch khám vào Firebase
      await newDocument.set(scheduleData, SetOptions(merge: true));
    }
    print('Lưu lịch khám thành công');
  }

  _addTime(List<int> options, int time) {
    for (int i = 0; i < 5; i++) {
      options.add((time * i));
    }
  }

  _calcTime(String startTime, String endTime, int time, int breakTime) {
    int startTimeToMinute = _convertTimeToMinutes(startTime);
    int endTimeToMinute = _convertTimeToMinutes(endTime);

    List<String> calcedTime = [];
    for (int i = 0;; i++) {
      int pointTime = startTimeToMinute + (time + breakTime) * i;
      int hour = pointTime ~/ 60;
      int minute = pointTime % 60;
      if (pointTime < endTimeToMinute &&
          (pointTime + time + breakTime) <= endTimeToMinute) {
        calcedTime.add("$hour:$minute");
      } else {
        break;
      }
    }

    return calcedTime;
  }

  _convertTimeToMinutes(String time) {
    String convertedTime = _convert12hTo24h(time);

    List<String> timeParts = convertedTime.split(':');
    int hours = int.parse(timeParts[0]);
    int minutes = int.parse(timeParts[1]);

    int totalMinutes = hours * 60 + minutes;
    return totalMinutes;
  }

  _convert12hTo24h(String time) {
    DateTime parsedTime = DateFormat('h:mm a').parse(time);
    String convertedTime = DateFormat('H:mm').format(parsedTime);
    return convertedTime;
  }

  _selectedOptions() {
    List<int> selectedOptions = [];

    for (int i = 1; i < _isSelectedOptions.length; i++) {
      if (_isSelectedOptions[i]) {
        selectedOptions.add(_options[i]);
      }
    }
    selectedOptions.sort((a, b) {
      return a.compareTo(b);
    });
    return selectedOptions;
  }
}
