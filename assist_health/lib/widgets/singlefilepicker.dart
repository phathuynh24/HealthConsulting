import 'package:assist_health/widgets/multiplefilepicker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_app_file/open_app_file.dart';
import 'package:flutter/material.dart';

class Singlefilepicker extends StatefulWidget {
  const Singlefilepicker({super.key});

  @override
  State<Singlefilepicker> createState() => _SinglefilepickerState();
}

class _SinglefilepickerState extends State<Singlefilepicker> {
  PlatformFile? file;
  Future<void> pickmultiplefile() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result != null) {
      List<PlatformFile> platformfile = result.files;
      setState(() {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return Multiplefilepicker(files: platformfile);
        }));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [
                Color.fromARGB(255, 49, 168, 215),
                Color.fromARGB(255, 58, 207, 100)
              ])),
            ),
            title: const Text(
              'File Picker',
              style: TextStyle(
                  color: Color.fromARGB(255, 59, 54, 54),
                  fontWeight: FontWeight.bold,
                  fontSize: 25),
            )),
        body: SingleChildScrollView(
          child: Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                ElevatedButton.icon(
                    onPressed: pickmultiplefile,
                    style: const ButtonStyle(
                        backgroundColor: MaterialStatePropertyAll(
                            Color.fromARGB(255, 99, 198, 47))),
                    icon: const Icon(Icons.file_copy),
                    label: const Text(
                      'Pick Multiple File',
                      style: TextStyle(fontSize: 25),
                    ))
              ])),
        ));
  }
}
