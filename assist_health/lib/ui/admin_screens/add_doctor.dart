import 'package:flutter/material.dart';

class AddDoctorPage extends StatefulWidget {
  const AddDoctorPage({Key? key}) : super(key: key);

  @override
  _AddDoctorPageState createState() => _AddDoctorPageState();
}

class _AddDoctorPageState extends State<AddDoctorPage> {
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _workplaceController;
  late TextEditingController _descriptionController;
  String _selectedSpecialty = 'Chirurgie plastique'; // Default value

  // List of specialties for the dropdown
  final List<String> _specialties = ['Chirurgie plastique', 'Dermatologie', 'Gynecologie', 'Ortopedie', 'Autre'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _addressController = TextEditingController();
    _workplaceController = TextEditingController();
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _workplaceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thêm Bác sĩ'),
      ),
         body: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('assets/doctor1.jpg'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Họ tên bác sĩ',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedSpecialty,
              onChanged: (newValue) {
                setState(() {
                  _selectedSpecialty = newValue!;
                });
              },
              items: _specialties.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              decoration: InputDecoration(
                labelText: 'Chuyên khoa',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _addressController,
              decoration: InputDecoration(
                labelText: 'Địa chỉ',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _workplaceController,
              decoration: InputDecoration(
                labelText: 'Nơi làm việc',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Mô tả thông tin',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _saveDoctor();
              },
              child: const Text('Thêm'),
            ),
          ],
        ),
      ),
     ),
    );
  }

  void _saveDoctor() {
    // TODO: Implement saving doctor information logic
  }
}
