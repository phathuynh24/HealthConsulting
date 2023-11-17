import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_file/open_file.dart';
import 'package:pinput/pinput.dart';

class RegisterCallStep4 extends StatefulWidget {
  final String uid;

  const RegisterCallStep4(this.uid, {super.key});

  @override
  State<RegisterCallStep4> createState() => _RegisterCallStep4();
}

class _RegisterCallStep4 extends State<RegisterCallStep4> {
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

  @override
  void dispose() {
    for (var controller in listController) {
      controller.dispose();
    }
    super.dispose();
  }

  List<File> selectedFiles = [];
  Future<void> pickmultiplefile() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['png', 'jpg', 'jpeg', 'mp4', 'doc', 'docx', 'pdf'],
    );
    if (result != null) {
      setState(() {
        selectedFiles.addAll(result.paths.map((path) => File(path!)));
      });
    }
  }

  void addNewTextFormField() {
    setState(() {
      listController.add(TextEditingController());
      _listTextLength.add(0);
      _listHintText.add("Câu hỏi");
      _listHelperText.add("Mỗi băn khoăn, lo lắng là một câu hỏi");
    });
  }

  void removeTextFormField(int index) {
    setState(() {
      if (listController[index].length == 0 &&
          index < listController.length - 1) {
        listController.removeAt(index);
        _listTextLength.removeAt(index);
        _listHintText.removeAt(index);
        _listHelperText.removeAt(index);
      }
    });
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
                '4. Điền bệnh án',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: List.generate(listController.length, (index) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        alignment: AlignmentDirectional.centerEnd,
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
                                if (index == listController.length - 1) {
                                  addNewTextFormField();
                                }
                              });
                            },
                          ),
                          if (index > 2)
                            Container(
                              margin: const EdgeInsets.only(
                                right: 10,
                              ),
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    removeTextFormField(index);
                                  });
                                },
                                child: CircleAvatar(
                                  backgroundColor: (_selectedField == index)
                                      ? Colors.purple
                                      : Colors.black45,
                                  radius: 12,
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 15,
                                  ),
                                ),
                              ),
                            ),
                        ],
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
            const SizedBox(height: 20),
            Container(
              margin: const EdgeInsets.all(10),
              child: GridView.builder(
                padding: EdgeInsets.zero,
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: selectedFiles.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 6.0,
                  crossAxisSpacing: 6.0,
                  childAspectRatio: 1.0,
                ),
                itemBuilder: (context, index) {
                  File file = selectedFiles[index];
                  String extension = file.path.split('.').last.toLowerCase();
                  return GestureDetector(
                    onTap: () {
                      OpenFile.open(file.path);
                    },
                    child: Stack(
                      children: [
                        LayoutBuilder(builder:
                            (BuildContext context, BoxConstraints constraints) {
                          return Center(
                            child: Container(
                              height: constraints.maxWidth - 10,
                              width: constraints.maxHeight - 10,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                color: Colors.grey,
                              ),
                              alignment: Alignment.center,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (extension == 'pdf')
                                    const Icon(Icons.picture_as_pdf, size: 50),
                                  if (extension == 'doc' || extension == 'docx')
                                    const Icon(Icons.description, size: 50),
                                  if (extension == 'mp4')
                                    const Icon(Icons.play_circle_filled,
                                        size: 50),
                                  if (extension == 'png' ||
                                      extension == 'jpg' ||
                                      extension == 'jpeg')
                                    SizedBox(
                                      height: constraints.maxWidth - 10,
                                      width: constraints.maxHeight - 10,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(6),
                                        child: Image.file(
                                          selectedFiles[index],
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
                                selectedFiles.removeAt(index);
                              });
                            },
                            child: const CircleAvatar(
                              backgroundColor: Colors.purple,
                              radius: 12,
                              child: Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 15,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
