import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:open_app_file/open_app_file.dart';
import 'package:flutter/material.dart';

class Multiplefilepicker extends StatefulWidget {
  List<PlatformFile>? files;
  Multiplefilepicker({required this.files, super.key});

  @override
  State<Multiplefilepicker> createState() => _MultiplefilepickerState();
}

class _MultiplefilepickerState extends State<Multiplefilepicker> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Files'),
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 47, 225, 121),
      ),
      body: ListView.builder(
          itemCount: widget.files!.length,
          itemBuilder: (context, index) {
            return buildfile(widget.files!, index);
          }),
    );
  }

  Widget buildfile(List<PlatformFile> file, index) {
    return InkWell(
      child: ListTile(
        title: Text(file[index].name),
        onTap: () => OpenAppFile.open(file[index].path.toString()),
      ),
    );
  }
}
