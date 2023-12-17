// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:assist_health/models/user/user_profile.dart';
import 'package:assist_health/others/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

// ignore: must_be_immutable
class AddOrEditProfileScreen extends StatefulWidget {
  bool isEdit;
  UserProfile? profile = UserProfile('', '', '', '', '', '', '', '');

  AddOrEditProfileScreen({
    super.key,
    required this.isEdit,
    this.profile,
  });

  @override
  State<AddOrEditProfileScreen> createState() => _AddOrEditProfileScreenState();
}

class _AddOrEditProfileScreenState extends State<AddOrEditProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  String? _uid;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();

  String _selectedGender = 'Nam';
  String _selectedRelationship = 'Khác';
  DateTime? _selectedDate;
  File? _selectedImage;

  bool _nameError = false;
  bool _phoneError = false;
  bool _dobError = false;

  bool _isSaving = false;
  bool _isMale = true;

  UserProfile? _currentUserProfile =
      UserProfile('', '', '', '', '', '', '', '');

  final List<String> _relationshipOptions = [
    'Cha',
    'Mẹ',
    'Con',
    'Chồng',
    'Vợ',
    'Khác'
  ];

  @override
  initState() {
    super.initState();
    _uid = _auth.currentUser!.uid;
    if (widget.isEdit) {
      _currentUserProfile = widget.profile;

      _nameController.text = _currentUserProfile!.name;
      _phoneController.text = _currentUserProfile!.phone;

      _dobController.text = _currentUserProfile!.doB;
      _selectedDate = DateFormat('dd/MM/yyyy').parse(_currentUserProfile!.doB);

      _selectedGender = _currentUserProfile!.gender;
      _isMale = (_selectedGender == 'Nam') ? true : false;

      _selectedRelationship = _currentUserProfile!.relationship;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: _isSaving,
      child: Stack(
        children: [
          Scaffold(
            appBar: AppBar(
              title:
                  Text((!widget.isEdit) ? 'Tạo hồ sơ mới' : 'Điều chỉnh hồ sơ'),
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
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 25, horizontal: 16),
                child: Column(
                  children: [
                    // Avt
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            _pickImage();
                          },
                          child: Stack(
                            children: [
                              Container(
                                width: 120,
                                height: 120,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Themes.primaryColor,
                                ),
                                child: _selectedImage != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(60),
                                        child: Image.file(_selectedImage!,
                                            fit: BoxFit.cover),
                                      )
                                    : (_currentUserProfile!.image != '')
                                        ? ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(60),
                                            child: Image.network(
                                                _currentUserProfile!.image,
                                                fit: BoxFit.cover),
                                          )
                                        : const SizedBox.shrink(),
                              ),
                              const Positioned(
                                bottom: 0,
                                right: 0,
                                child: CircleAvatar(
                                  backgroundColor: Themes.iconClr,
                                  child: Icon(Icons.camera_alt,
                                      color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Họ tên
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                      child: Row(
                        children: [
                          Text(
                            "Họ và tên",
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
                        controller: _nameController,
                        decoration: InputDecoration(
                          hintText: 'Họ và tên của bạn',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          errorText: _nameError ? 'Vui lòng nhập họ tên' : null,
                          errorStyle: const TextStyle(
                            fontSize: 14,
                            color: Colors.red,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 12),
                        ),
                        onChanged: (value) {
                          bool nameError;
                          if (_nameController.text.isEmpty ||
                              _nameController.text.trim() == '') {
                            nameError = true;
                          } else {
                            nameError = false;
                          }
                          setState(() {
                            _nameError = nameError;
                          });
                        }),

                    const SizedBox(height: 10),
                    // Số điện thoại
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                      child: Row(
                        children: [
                          Text(
                            "Số điện thoại",
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
                        maxLength: 10,
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          hintText: 'Nhập số điện thoại',
                          counterText: '',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          errorText: _phoneError
                              ? 'Vui lòng nhập số điện thoại bệnh nhân'
                              : null,
                          errorStyle: const TextStyle(
                            fontSize: 14,
                            color: Colors.red,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 12),
                        ),
                        onChanged: (value) {
                          bool phoneError;
                          if (value.length == 10 && value.startsWith('0')) {
                            phoneError = false;
                          } else {
                            phoneError = true;
                          }
                          setState(() {
                            _phoneError = phoneError;
                          });
                        }),
                    const SizedBox(height: 10),
                    // Ngày sinh
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                      child: Row(
                        children: [
                          Text(
                            "Ngày sinh",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          Text(
                            ' *',
                            style: TextStyle(color: Colors.red),
                          )
                        ],
                      ),
                    ),

                    InkWell(
                      onTap: () {
                        _selectDate(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: _dobError ? Colors.red : Colors.grey,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Text(
                                (_selectedDate == null)
                                    ? 'Vui lòng chọn ngày sinh'
                                    : DateFormat('dd/MM/yyyy')
                                        .format(_selectedDate!),
                                style: const TextStyle(
                                    fontSize: 16, color: Colors.black54),
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Icon(
                              Icons.calendar_month_sharp,
                              size: 30,
                              color: Colors.grey,
                            )
                          ],
                        ),
                      ),
                    ),
                    Visibility(
                      visible: _dobError,
                      child: Container(
                        alignment: Alignment.centerLeft,
                        margin: const EdgeInsets.only(left: 6),
                        padding: const EdgeInsets.all(8),
                        child: const Text(
                          'Vui lòng chọn ngày sinh',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Giới tính
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                      child: Row(
                        children: [
                          Text(
                            "Giới tính",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          Text(
                            ' *',
                            style: TextStyle(color: Colors.red),
                          )
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: () {
                            setState(() {
                              _isMale = true;

                              _selectedGender = 'Nam';
                            });
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.43,
                            decoration: BoxDecoration(
                              color: _isMale
                                  ? Colors.blue.withOpacity(0.1)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: _isMale ? Colors.blue : Colors.grey,
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Radio(
                                        value: 'Nam',
                                        groupValue: _selectedGender,
                                        onChanged: (value) {
                                          setState(() {
                                            _isMale = true;
                                            _selectedGender = value!;
                                          });
                                        },
                                      ),
                                      Text(
                                        'Nam',
                                        style: TextStyle(
                                          color: _isMale
                                              ? Colors.blue
                                              : Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.male,
                                  color: Colors.blue,
                                ),
                                const SizedBox(
                                  width: 15,
                                ),
                              ],
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            setState(() {
                              _isMale = false;
                              _selectedGender = 'Nữ';
                            });
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.43,
                            decoration: BoxDecoration(
                              color: !_isMale
                                  ? Colors.blue.withOpacity(0.1)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: !_isMale ? Colors.blue : Colors.grey,
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Radio(
                                        value: 'Nữ',
                                        groupValue: _selectedGender,
                                        onChanged: (value) {
                                          setState(() {
                                            _isMale = false;
                                            _selectedGender = value!;
                                          });
                                        },
                                      ),
                                      Text(
                                        'Nữ',
                                        style: TextStyle(
                                          color: _isMale
                                              ? Colors.black
                                              : Colors.blue,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.female,
                                  color: Colors.redAccent,
                                ),
                                const SizedBox(
                                  width: 15,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Mối quan hệ
                    Visibility(
                      visible: (widget.isEdit &&
                              _currentUserProfile!.idDoc == 'main_profile')
                          ? false
                          : true,
                      child: Column(
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 8, horizontal: 5),
                            child: Row(
                              children: [
                                Text(
                                  "Mối quan hệ",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                Text(
                                  ' *',
                                  style: TextStyle(color: Colors.red),
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 110,
                            width: MediaQuery.of(context).size.width,
                            child: GridView.builder(
                              itemCount: _relationshipOptions.length,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                childAspectRatio: 2.5,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                              ),
                              itemBuilder: (BuildContext context, int index) {
                                final relationship =
                                    _relationshipOptions[index];
                                bool isSelected =
                                    _selectedRelationship == relationship;
                                return InkWell(
                                  onTap: () {
                                    setState(() {
                                      _selectedRelationship = relationship;
                                    });
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? Colors.blue.withOpacity(0.1)
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: isSelected
                                            ? Colors.blue
                                            : Colors.grey,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Radio(
                                          value: relationship,
                                          groupValue: _selectedRelationship,
                                          onChanged: (value) {
                                            setState(() {
                                              _selectedRelationship = value!;
                                            });
                                          },
                                        ),
                                        Text(
                                          relationship,
                                          style: TextStyle(
                                            color: isSelected
                                                ? Colors.blue
                                                : Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Nút lưu
            bottomNavigationBar: Container(
              margin: const EdgeInsets.symmetric(
                vertical: 10,
                horizontal: 15,
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                onPressed: _saveDataToFirestore,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    (!widget.isEdit) ? 'Tạo hồ sơ' : 'Lưu',
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              ),
            ),
          ),
          // Trạng thái saving
          if (_isSaving)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  _validateInputs() {
    setState(() {
      _nameError = _nameController.text.isEmpty;
      _phoneError = _phoneController.text.isEmpty;
      _dobError = _dobController.text.isEmpty;
    });

    if (!_nameError && !_phoneError && !_dobError) {
      return true;
    }
    return false;
  }

  _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _dobError = false;
        _selectedDate = picked;
        _dobController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path);
      });
    }
  }

  _saveDataToFirestore() async {
    if (!_validateInputs()) return;

    setState(() {
      _isSaving = true;
    });
    try {
      String idProfile = generateTenDigitUuid();
      String name = _nameController.text;
      String phone = _phoneController.text;
      String dob = _dobController.text;
      String gender = _selectedGender;
      String relationship = _selectedRelationship;
      String idDoc;
      String imageURL;
      if (widget.isEdit) {
        idDoc = _currentUserProfile!.idDoc;
        imageURL = _currentUserProfile!.image;
      } else {
        idDoc = '${DateTime.now()}';
        imageURL = '';
      }

      final userDocumentRef = _firestore
          .collection('users')
          .doc(_uid)
          .collection('health_profiles')
          .doc(idDoc);

      if (widget.isEdit) {
        // Cập nhật doc để lưu dữ liệu
        await userDocumentRef.update(
          {
            'name': name,
            'phone': phone,
            'doB': dob,
            'gender': gender,
            'relationship': relationship,
            'idDoc': idDoc,
          },
        );
      } else {
        // Tạo doc để lưu dữ liệu
        await userDocumentRef.set(
          {
            'name': name,
            'phone': phone,
            'doB': dob,
            'gender': gender,
            'relationship': relationship,
            'idDoc': idDoc,
            'idProfile': idProfile,
            'imageURL': imageURL,
          },
          SetOptions(merge: true),
        );
      }
      if (_selectedImage != null) {
        // Lưu ảnh lên Storage

        final imageReference =
            _storage.ref().child('images/${DateTime.now()}.png');
        final uploadTask = imageReference.putFile(_selectedImage!);
        final storageTaskSnapshot = await uploadTask.whenComplete(() => null);

        // Lưu đường dẫn ảnh
        imageURL = await storageTaskSnapshot.ref.getDownloadURL();
        await userDocumentRef.update({'imageURL': imageURL});
      }

      UserProfile tempUserProfile = UserProfile(
          name, phone, gender, dob, relationship, imageURL, idDoc, idProfile);
      //Quay trở lại màn hình trước đó
      if (widget.isEdit) {
        Navigator.pop(context, {'isEdited': true, 'profile': tempUserProfile});
      } else {
        Navigator.pop(context, true);
      }
    } catch (error) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Lỗi'),
            content: const Text(
                'Trong quá trình lưu đã xảy ra lỗi. Bạn vui lòng thử lại sau!'),
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
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  String generateTenDigitUuid() {
    final uuid = const Uuid().v4();
    final numericUuid = uuid.replaceAll(RegExp('[^0-9]'), '');
    final tenDigitUuid = numericUuid.substring(0, 10);
    return 'IDP$tenDigitUuid';
  }
}
