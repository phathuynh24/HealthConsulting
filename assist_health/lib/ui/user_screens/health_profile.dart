import 'dart:io';
import 'package:assist_health/others/theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

class HealthProfileScreen extends StatefulWidget {
  const HealthProfileScreen({super.key});

  @override
  _HealthProfileScreenState createState() => _HealthProfileScreenState();
}

class Vaccination {
  final String name;
  final String date;
  Vaccination({required this.name, required this.date});
}

class LabTestResult {
  final String name;
  final String filePath;
  LabTestResult({required this.name, required this.filePath});
}

class _HealthProfileScreenState extends State<HealthProfileScreen> {
  TextEditingController weightController = TextEditingController();
  TextEditingController heightController = TextEditingController();
  TextEditingController bloodPressureController = TextEditingController();
  TextEditingController temperatureController = TextEditingController();
  double bmi = 0.0;
  String bmiStatus = '';
  List<Vaccination> vaccinations = [];
  List<LabTestResult> labTestResults = [];

  File? selectedImage;
  List<File> selectedFiles = [];

  late User? _currentUser;
  late String _userHealthProfileCollection;
  late DocumentReference _userDocumentRef;

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;

    _userHealthProfileCollection =
        'health_profiles/${_currentUser?.uid ?? 'unknown_user'}';
    _userDocumentRef =
        FirebaseFirestore.instance.doc(_userHealthProfileCollection);
    // Gọi phương thức để tải dữ liệu từ Firebase khi trang được khởi tạo
    loadDataFromFirestore();
  }

  @override
  void dispose() {
    weightController.dispose();
    heightController.dispose();
    bloodPressureController.dispose();
    temperatureController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Themes.backgroundClr,
        appBar: AppBar(
          title: const Text('Hồ sơ sức khỏe cá nhân'),
          centerTitle: true,
          backgroundColor: Themes.hearderClr,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Upload Photo',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () {
                    pickImage();
                  },
                  child: Container(
                    width: 100,
                    height: 100,
                    color: Colors.grey,
                    child: selectedImage != null
                        ? Image.file(selectedImage!, fit: BoxFit.cover)
                        : const Icon(Icons.camera_alt, color: Themes.iconClr),
                  ),
                ),

                const SizedBox(height: 16),
                Column(
                  children: [
                    const Text(
                      'Chỉ số gần đây',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                                decoration: BoxDecoration(
                                    shape: BoxShape.rectangle,
                                    color: Colors.purple,
                                    borderRadius: BorderRadius.circular(10)),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 2, vertical: 8),
                                child: Transform.rotate(
                                  angle: 90 *
                                      3.1415926535 /
                                      180, // Chuyển đổi góc từ độ sang radian
                                  child: const Icon(
                                    Icons.straighten,
                                    color: Colors.white,
                                    size: 25,
                                  ),
                                )),
                            const SizedBox(width: 10),
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '170 cm',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  'Chiều cao',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Container(
                                decoration: BoxDecoration(
                                    shape: BoxShape.rectangle,
                                    color: Colors.purple,
                                    borderRadius: BorderRadius.circular(10)),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 2, vertical: 8),
                                child: const Icon(
                                  Icons.scale,
                                  color: Colors.white,
                                  size: 25,
                                )),
                            const SizedBox(width: 10),
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '80 kg',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  'Cân nặng',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              color: Colors.purple,
                              borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 2, vertical: 8),
                          child: const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 25,
                          ),
                        ),
                      ],
                    ),
                    const Text(
                      'Weight (kg)',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: weightController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Enter weight',
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Height (cm)',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: heightController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Enter height',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Themes.buttonClr,
                  ),
                  onPressed: () {
                    calculateBMI();
                  },
                  child: const Text('Calculate BMI'),
                ),

                const SizedBox(height: 16),

                Text(
                  'BMI: ${bmi.toStringAsFixed(1)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),

                Text(
                  'BMI Status: $bmiStatus',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),

                const SizedBox(height: 16),

                const Text(
                  'Blood Pressure',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                // Add blood pressure input fields (using TextFields)
                TextField(
                  controller: bloodPressureController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Enter blood pressure',
                  ),
                ),
                const SizedBox(height: 16),

                const Text(
                  'Temperature',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                // Add temperature input field (using TextField)
                TextField(
                  controller: temperatureController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Enter temperature',
                  ),
                ),
                const SizedBox(height: 16),

                const Text(
                  'Vaccination History',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Themes.buttonClr,
                  ),
                  onPressed: () {
                    addVaccination();
                  },
                  child: const Text('Add Vaccination'),
                ),
                const SizedBox(height: 8),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: vaccinations.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(vaccinations[index].name),
                      subtitle: Text(vaccinations[index].date),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          setState(() {
                            vaccinations.removeAt(index);
                          });
                        },
                      ),
                    );
                  },
                ),

                const SizedBox(height: 16),

                const Text(
                  'Lab Test Results',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Themes.buttonClr,
                  ),
                  onPressed: () {
                    pickFiles();
                  },
                  child: const Text('Pick Files'),
                ),
                const SizedBox(height: 8),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: selectedFiles.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: GestureDetector(
                        onTap: () {
                          openFile(selectedFiles[index]);
                        },
                        child: Text(selectedFiles[index].path),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          setState(() {
                            selectedFiles.removeAt(index);
                          });
                        },
                      ),
                    );
                  },
                ),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Themes.buttonClr,
                    ),
                    onPressed: () {
                      saveDataToFirestore();
                    },
                    child: const Text('Save'))
              ],
            ),
          ),
        ));
  }

  void openFile(File file) {
    String filePath = file.path.toLowerCase();

    // Kiểm tra định dạng của file và mở tương ứng
    if (filePath.endsWith('.txt')) {
      // Mở file văn bản
      OpenFile.open(file.path);
      // OpenFile.openText(file.path);
    } else if (filePath.endsWith('.jpg') ||
        filePath.endsWith('.jpeg') ||
        filePath.endsWith('.png')) {
      // Mở file hình ảnh
      OpenFile.open(file.path);
    } else {
      // Xử lý các định dạng khác tùy thuộc vào nhu cầu của bạn
      // ...
    }
  }

  void pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        selectedImage = File(pickedImage.path);
      });
    }
  }

  void calculateBMI() {
    double weight = double.tryParse(weightController.text) ?? 0.0;
    double height = double.tryParse(heightController.text) ?? 0.0;
    if (weight > 0 && height > 0) {
      double bmiValue = weight / ((height / 100) * (height / 100));
      setState(() {
        bmi = bmiValue;
        if (bmi < 18.5) {
          bmiStatus = 'Underweight';
        } else if (bmi < 25.0) {
          bmiStatus = 'Normal weight';
        } else if (bmi < 30.0) {
          bmiStatus = 'Overweight';
        } else {
          bmiStatus = 'Obese';
        }
      });
    }
  }

  void loadDataFromFirestore() async {
    try {
      DocumentSnapshot document = await _userDocumentRef.get();

      if (document.exists) {
        // Cập nhật các giá trị từ Firestore vào các text controllers và biến thành viên
        setState(() {
          weightController.text = document['weight'].toString();
          heightController.text = document['height'].toString();
          bloodPressureController.text = document['bloodPressure'];
          temperatureController.text = document['temperature'];
        });

        // Kiểm tra và tải ảnh từ Firestore
        if (document['imageURL'] != null) {
          String imageURL = document['imageURL'];
          // Tạo một đối tượng File từ URL
          File imageFile = await getImageFileFromURL(imageURL);
          // Cập nhật ảnh đã tải về vào biến thành viên
          setState(() {
            selectedImage = imageFile;
          });
        }

        // Kiểm tra và tải danh sách các file từ Firestore
        if (document['fileURLs'] != null) {
          List<String> fileURLs = List<String>.from(document['fileURLs']);
          List<File> files = [];

          for (String fileURL in fileURLs) {
            // Tạo một đối tượng File từ URL
            File file = await getFileFromURL(fileURL);
            // Thêm file đã tải về vào danh sách
            files.add(file);
          }

          // Cập nhật danh sách các file đã tải về vào biến thành viên
          setState(() {
            selectedFiles = files;
          });
        }
        // Kiểm tra và tải danh sách lịch sử tiêm chủng từ Firestore
        //  if (document['vaccinations'] != null) {
        List<Map<String, dynamic>> vaccinationsData =
            List<Map<String, dynamic>>.from(document['vaccinations']);

        List<Vaccination> loadedVaccinations = vaccinationsData
            .map((data) => Vaccination(
                  name: data['name'],
                  date: data['date'],
                ))
            .toList();

        // Cập nhật danh sách lịch sử tiêm chủng
        setState(() {
          vaccinations = loadedVaccinations;
        });
      }
      // }
      // else {
      //   showDialog(
      //     context: context,
      //     builder: (BuildContext context) {
      //       return AlertDialog(
      //         title: Text('No Data'),
      //         content: Text('No data available.'),
      //         actions: [
      //           TextButton(
      //             onPressed: () {
      //               Navigator.of(context).pop();
      //             },
      //             child: Text('OK'),
      //           ),
      //         ],
      //       );
      //     },
      //   );
      // }
    } catch (error) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('An error occurred while loading data.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  Future<File> getImageFileFromURL(String url) async {
    // Sử dụng package http để tải ảnh từ URL
    var response = await http.get(Uri.parse(url));
    var tempDir = await getTemporaryDirectory();
    File file = File('${tempDir.path}/temp_image.png');
    await file.writeAsBytes(response.bodyBytes);
    return file;
  }

  Future<File> getFileFromURL(String url) async {
    // Sử dụng package http để tải file từ URL
    var response = await http.get(Uri.parse(url));
    var tempDir = await getTemporaryDirectory();
    File file = File('${tempDir.path}/${DateTime.now()}.png');
    await file.writeAsBytes(response.bodyBytes);
    return file;
  }

  void saveDataToFirestore() async {
    try {
      // Lưu trữ thông tin từ các text controllers vào các biến
      double weight = double.tryParse(weightController.text) ?? 0.0;
      double height = double.tryParse(heightController.text) ?? 0.0;
      String bloodPressure = bloodPressureController.text;
      String temperature = temperatureController.text;

      // Tạo một document mới trong collection "health_profiles"
      await _userDocumentRef.set({
        'weight': weight,
        'height': height,
        'bloodPressure': bloodPressure,
        'temperature': temperature,
        'vaccinations': vaccinations
            .map((vaccination) => {
                  'name': vaccination.name,
                  'date': vaccination.date,
                })
            .toList(),
      }, SetOptions(merge: true));
      // Lưu trữ vaccinations vào subcollection "vaccinations" của document mới được tạo

      // Lưu trữ hình ảnh vào Firebase Storage và lấy URL của hình ảnh đã lưu
      if (selectedImage != null) {
        Reference imageReference = FirebaseStorage.instance
            .ref()
            .child('images/${DateTime.now()}.png');
        UploadTask uploadTask = imageReference.putFile(selectedImage!);
        TaskSnapshot storageTaskSnapshot =
            await uploadTask.whenComplete(() => null);
        String imageURL = await storageTaskSnapshot.ref.getDownloadURL();

        // Cập nhật URL của hình ảnh đã lưu vào Firestore
        await _userDocumentRef.update({'imageURL': imageURL});
      }

      // Lưu trữ các tệp vào Firebase Storage và lấy URL của các tệp đã lưu
      List<String> fileURLs = [];
      for (var selectedFile in selectedFiles) {
        Reference fileReference = FirebaseStorage.instance.ref().child(
            'files/${DateTime.now()}_${selectedFile.path.split('/').last}');
        UploadTask uploadTask = fileReference.putFile(selectedFile);
        TaskSnapshot storageTaskSnapshot =
            await uploadTask.whenComplete(() => null);
        String fileURL = await storageTaskSnapshot.ref.getDownloadURL();
        fileURLs.add(fileURL);
      }

      // Cập nhật URL của các tệp đã lưu vào Firestore
      await _userDocumentRef.update({'fileURLs': fileURLs});

      // Hiển thị thông báo thành công
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Success'),
            content: const Text('Data saved successfully.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } catch (error) {
      // Hiển thị thông báo lỗi
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('An error occurred. Please try again later.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  void addVaccination() async {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController dateController = TextEditingController();
    DateTime currentDate = DateTime.now();

    DateTime? selectedDate;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Vaccination'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Vaccine Name',
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () async {
              selectedDate = await showDatePicker(
                context: context,
                initialDate: currentDate,
                firstDate: DateTime(1900),
                lastDate: DateTime(2100),
              );
              // Update the text field when a date is selected
              if (selectedDate != null) {
                dateController.text =
                    selectedDate!.toLocal().toString().split(' ')[0];
              }
              // Handle the selected date
            },
            child: AbsorbPointer(
              child: TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Date',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                controller: dateController,
              ),
            ),
          ),
        ]),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (selectedDate != null) {
                setState(() {
                  vaccinations.add(
                    Vaccination(
                      name: nameController.text,
                      date: selectedDate!.toLocal().toString().split(' ')[0],
                    ),
                  );
                  Navigator.pop(context);
                });
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void pickFiles() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result != null) {
      setState(() {
        selectedFiles.addAll(result.paths.map((path) => File(path!)));
      });
    }
  }
}
