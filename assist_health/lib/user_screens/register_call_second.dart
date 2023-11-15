import 'dart:io';

import 'package:assist_health/widgets/multiplefilepicker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_app_file/open_app_file.dart';

class RegisterCallThird extends StatefulWidget {
  final String uid;

  const RegisterCallThird(this.uid, {super.key});

  @override
  State<RegisterCallThird> createState() => _RegisterCallThird();
}

class _RegisterCallThird extends State<RegisterCallThird> {
  final List<int> _listTextLength = [0, 0, 0];
  final List<String> _listHintText = [
    "Lý do khám chính",
    "Mô tả chi tiết",
    "Câu hỏi"
  ];
  final List<String> _listHelperText = [
    "Lý do khám chính từ 7-10 từ",
    "Triệu chứng thế nào? Diễn biến ra sao? Các liệu pháp điều trị? Hiệu quả đạt được? Vấn đề còn tồn đọng?",
    "Mỗi băn khoăn, lo lắng là một câu hỏi",
  ];

  int _selectedField = -1;
  List<TextEditingController> listController =
      List.generate(3, (index) => TextEditingController());

  List<File> selectedFiles = [];
  Future<void> pickmultiplefile() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result != null) {
      setState(() {
        selectedFiles.addAll(result.paths.map((path) => File(path!)));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đăng ký dịch vụ'),
        centerTitle: true,
        backgroundColor: const Color(0xFF7165D6),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.all(15),
              child: Text(
                '3. Điền bệnh án',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: List.generate(3, (index) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: listController[index],
                        decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          hintText: _listHintText[index],
                        ),
                        maxLines: ((index == 1) ? 8 : 1),
                        inputFormatters: [
                          LengthLimitingTextInputFormatter((index == 0)
                              ? 50
                              : (index == 1)
                                  ? 1000
                                  : 100),
                        ],
                        onTap: () {
                          setState(() {
                            _selectedField = index;
                          });
                        },
                        onChanged: (value) {
                          setState(() {
                            _listTextLength[index] = value.length;
                          });
                        },
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Expanded(
                            child: Text(
                              _selectedField == index
                                  ? _listHelperText[index]
                                  : "",
                              style: const TextStyle(
                                color: Colors.grey,
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ),
                          if (index != 1)
                            SizedBox(
                              width: 50,
                              child: Text(
                                _selectedField == index
                                    ? "${_listTextLength[index]}/${(index == 0) ? 50 : (index == 1) ? 1000 : 100}"
                                    : "",
                                style: const TextStyle(
                                  color: Colors.grey,
                                ),
                                textAlign: TextAlign.right,
                              ),
                            )
                          else
                            const SizedBox(),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  );
                }),
              ),
            ),
            ElevatedButton(
              onPressed: pickmultiplefile,
              child: const Text("Chọn File"),
            ),
            // Column(
            //   children: [
            //     Text("Picked PDFs and Documents:"),
            //     Wrap(
            //       children: pdfFiles.map((pdfFile) {
            //         return Text(pdfFile.path);
            //       }).toList(),
            //     ),
            //   ],
            // ),
            // Column(
            //   children: [
            //     Text("Picked Videos:"),
            //     Wrap(
            //       children: videoFiles.map((videoFile) {
            //         return Text(videoFile.path);
            //       }).toList(),
            //     ),
            //   ],
            // ),
          ],
        ),
      ),
    );
  }
}
