// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:assist_health/src/models/other/appointment_schedule.dart';
import 'package:assist_health/src/models/other/result.dart';
import 'package:assist_health/src/others/theme.dart';
import 'package:assist_health/src/widgets/doctor_navbar.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:open_file/open_file.dart';

// ignore: must_be_immutable
class ExaminationResultsScreen extends StatefulWidget {
  AppointmentSchedule appointmentSchedule;
  bool isFromCall;
  ExaminationResultsScreen(
      {super.key, required this.appointmentSchedule, required this.isFromCall});

  @override
  State<ExaminationResultsScreen> createState() =>
      _ExaminationResultsScreenState();
}

class _ExaminationResultsScreenState extends State<ExaminationResultsScreen> {
  final TextEditingController _resultController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  bool _resultError = false;
  List<File>? _selectedFiles = [];

  AppointmentSchedule? _appointmentSchedule;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _appointmentSchedule = widget.appointmentSchedule;
  }

  @override
  void dispose() {
    super.dispose();
    _resultController.dispose();
    _noteController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (widget.isFromCall) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const DoctorNavBar()),
            (route) => false,
          );
        }

        return true;
      },
      child: Stack(
        children: [
          Scaffold(
            appBar: AppBar(
              title: const Text('Trả kết quả'),
              foregroundColor: Colors.white,
              centerTitle: true,
              automaticallyImplyLeading: !widget.isFromCall,
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
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                      child: Row(
                        children: [
                          Text(
                            "Chẩn đoán",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          Text(
                            ' *',
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                    TextField(
                        controller: _resultController,
                        decoration: InputDecoration(
                          hintText: 'Chẩn đoán bệnh',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          errorText:
                              _resultError ? 'Vui lòng nhập chẩn đoán' : null,
                          errorStyle: const TextStyle(
                            fontSize: 14,
                            color: Colors.red,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 12),
                        ),
                        maxLines: 2,
                        onChanged: (value) {
                          bool resultError;
                          if (_resultController.text.isEmpty ||
                              _resultController.text.trim() == '') {
                            resultError = true;
                          } else {
                            resultError = false;
                          }
                          setState(() {
                            _resultError = resultError;
                          });
                        }),
                    const SizedBox(
                      height: 16,
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                      child: Text(
                        "Ghi chú",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    TextField(
                      controller: _noteController,
                      decoration: InputDecoration(
                        hintText: 'Ghi chú dành cho bệnh nhân',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 12),
                      ),
                      maxLines: 4,
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 5),
                      child: Text(
                        'Hình ảnh (${_selectedFiles!.length}/6)',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(
                        vertical: 8,
                      ),
                      child: GridView.builder(
                        padding: EdgeInsets.zero,
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _selectedFiles!.length + 1,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 6,
                          crossAxisSpacing: 6,
                          childAspectRatio: 1,
                        ),
                        itemBuilder: (context, index) {
                          if (index != _selectedFiles!.length) {
                            File file = _selectedFiles![index];
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
                                          borderRadius:
                                              BorderRadius.circular(6),
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
                                              const Icon(
                                                  Icons.play_circle_filled,
                                                  size: 50),
                                            if (extension == 'png' ||
                                                extension == 'jpg' ||
                                                extension == 'jpeg')
                                              SizedBox(
                                                height:
                                                    constraints.maxWidth - 10,
                                                width:
                                                    constraints.maxHeight - 10,
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
                                          File file = _selectedFiles![index];
                                          // Xóa tệp cục bộ
                                          file.deleteSync();
                                          // Xóa tệp khỏi danh sách
                                          _selectedFiles!.removeAt(index);
                                        });
                                      },
                                      child: const CircleAvatar(
                                        backgroundColor: Colors.red,
                                        radius: 12,
                                        child: Icon(
                                          Icons.remove,
                                          color: Colors.white,
                                          size: 15,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          } else {
                            if (_selectedFiles!.length <= 5) {
                              return GestureDetector(
                                onTap: () {
                                  _showImageBottomSheet(context);
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.add,
                                      size: 35,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              );
                            }
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            bottomNavigationBar: Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                  border: Border(
                      top: BorderSide(
                color: Colors.blueGrey,
                width: 0.3,
              ))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Nút gửi kết quả sau
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        if (widget.isFromCall) {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const DoctorNavBar()),
                            (route) => false,
                          );
                        } else {
                          Navigator.of(context).pop(true);
                        }
                      },
                      child: Container(
                        height: 50,
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 15),
                        margin: const EdgeInsets.only(left: 10, right: 5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: Colors.blue), // Thêm viền để khác biệt
                          color: Colors.white, // Nền trắng để nhẹ nhàng hơn
                        ),
                        child: const Center(
                          child: Text(
                            'Gửi sau',
                            style: TextStyle(
                              color: Colors
                                  .blue, // Chữ màu xanh để đồng bộ với viền
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Nút gửi kết quả ngay
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        if (_resultController.text != '') {
                          Result result = Result(
                            diagnose: _resultController.text,
                            note: _noteController.text,
                            idDoctor: _appointmentSchedule!.doctorInfo!.uid,
                            doctorName: _appointmentSchedule!.doctorInfo!.name,
                            idSchedule: _appointmentSchedule!.idDoc,
                            idUser: _appointmentSchedule!.idDocUser,
                            idProfile: _appointmentSchedule!.userProfile!.idDoc,
                            nameProfile:
                                _appointmentSchedule!.userProfile!.name,
                            appointmentCode:
                                _appointmentSchedule!.appointmentCode!,
                            dateExamination: _appointmentSchedule!.selectedDate,
                            timeExamination: _appointmentSchedule!.time,
                            timeResult: DateTime.now(),
                            listFiles: _selectedFiles,
                          );
                          setState(() {
                            _isSaving = true;
                          });

                          await result.saveResultToFirebase();

                          _appointmentSchedule!.updateAppointmentIsResult();

                          if (widget.isFromCall) {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const DoctorNavBar()));
                          } else {
                            Navigator.of(context).pop(true);
                          }

                          setState(() {
                            _isSaving = false;
                          });
                        } else {
                          setState(() {
                            _resultError = true;
                          });
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        height: 50,
                        margin: const EdgeInsets.only(
                          left: 5,
                          right: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Themes.gradientDeepClr,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Center(
                          child: Text(
                            'Gửi kết quả',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
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
          if (_isSaving)
            const Opacity(
              opacity: 0.5, // Độ mờ của lớp phủ
              child: ModalBarrier(dismissible: false, color: Colors.black),
            ),
          if (_isSaving)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }

  void _showImageBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
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
      },
    );
  }

  Future<void> pickMultipleFile() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['png', 'jpg', 'jpeg'],
    );

    if (result != null) {
      final List<File> selectedFiles = result.paths
          .map((path) => File(path!))
          .where((file) => file.existsSync()) // Lọc bỏ các tệp không tồn tại
          .toList();

      if (_selectedFiles!.length + selectedFiles.length <= 6) {
        setState(() {
          _selectedFiles!.addAll(selectedFiles);
        });
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Thông báo'),
            content: const Text('Bạn chỉ được chọn tối đa 6 ảnh.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Đã hiểu'),
              ),
            ],
          ),
        );
      }
    }
  }

  Future<void> captureImage() async {
    final imagePicker = ImagePicker();
    final pickedFile = await imagePicker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _selectedFiles!.add(File(pickedFile.path));
      });
    }
  }
}
