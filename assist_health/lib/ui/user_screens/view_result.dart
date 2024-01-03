// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:assist_health/models/other/result.dart';
import 'package:assist_health/others/theme.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

// ignore: must_be_immutable
class ViewResultsScreen extends StatefulWidget {
  Result result;
  ViewResultsScreen({super.key, required this.result});

  @override
  State<ViewResultsScreen> createState() => _ExaminationResultsScreenState();
}

class _ExaminationResultsScreenState extends State<ViewResultsScreen> {
  final TextEditingController _resultController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  Result? _result;

  @override
  void initState() {
    super.initState();
    _result = widget.result;
    _resultController.text = _result!.diagnose!;
    _noteController.text = _result!.note!;

    loadFileFromStorage();
    print(_result!.listUrls!.length + 100);
  }

  @override
  void dispose() {
    super.dispose();
    _resultController.dispose();
    _noteController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kết quả khám'),
        foregroundColor: Colors.white,
        centerTitle: true,
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
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
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
                readOnly: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                ),
                maxLines: 2,
              ),
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
                readOnly: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                ),
                maxLines: 4,
              ),
              const SizedBox(
                height: 16,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                child: Text(
                  'Hình ảnh (${_result!.listUrls!.length}/6)',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              GridView.builder(
                  padding: EdgeInsets.zero,
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _result!.listUrls!.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 6,
                    crossAxisSpacing: 6,
                    childAspectRatio: 1,
                  ),
                  itemBuilder: (context, index) {
                    if (_result!.listFiles!.isEmpty) {
                      return LayoutBuilder(builder:
                          (BuildContext context, BoxConstraints constraints) {
                        return Center(
                          child: Container(
                            height: constraints.maxWidth - 10,
                            width: constraints.maxHeight - 10,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              color: Colors.grey.shade300,
                            ),
                            alignment: Alignment.center,
                            child: const SizedBox(
                                height: 25,
                                width: 25,
                                child: CircularProgressIndicator()),
                          ),
                        );
                      });
                    }

                    File file = _result!.listFiles![index];
                    String extension = file.path.split('.').last.toLowerCase();

                    return GestureDetector(
                      onTap: () {
                        OpenFile.open(file.path);
                      },
                      child: LayoutBuilder(builder:
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
                                if (extension == '')
                                  const CircularProgressIndicator(),
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
                    );
                  })
            ],
          ),
        ),
      ),
    );
  }

  Future<File> getFileFromURL(String url) async {
    // Sử dụng package http để tải file từ URL
    var response = await http.get(Uri.parse(url));
    var tempDir = await getTemporaryDirectory();
    File file =
        File('${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.png');

    await file.writeAsBytes(response.bodyBytes);
    return file;
  }

  loadFileFromStorage() async {
    List<File> files = [];

    for (String fileURL in _result!.listUrls!) {
      // Tạo một đối tượng File từ URL
      File file = await getFileFromURL(fileURL);
      // Thêm file đã tải về vào danh sách
      files.add(file);
    }

    setState(() {
      _result!.listFiles = files;
    });
  }
}
