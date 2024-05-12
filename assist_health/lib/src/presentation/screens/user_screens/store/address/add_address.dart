import 'dart:convert';
import 'package:assist_health/src/others/theme.dart';
import 'package:assist_health/src/presentation/screens/user_screens/store/address/list_addresses.dart';
import 'package:assist_health/src/presentation/screens/user_screens/store/product_detail_screen.dart';
import 'package:assist_health/src/presentation/screens/user_screens/store/purchase_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

class AddAddressScreen extends StatefulWidget {
  const AddAddressScreen({Key? key}) : super(key: key);

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  bool isDefault = false;
  String? selectedCity;
  String? selectedDistrict;
  String? selectedWard;

  List<String> cities = [];
  List<String> districts = [];
  List<String> wards = [];

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchCityData();
  }

  Future<void> fetchCityData() async {
    final response = await http.get(Uri.parse(
        'https://raw.githubusercontent.com/kenzouno1/DiaGioiHanhChinhVN/master/data.json'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        cities = data.map<String>((item) => item['Name'].toString()).toList();
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<void> fetchDistrictData(String cityName) async {
    final response = await http.get(Uri.parse(
        'https://raw.githubusercontent.com/kenzouno1/DiaGioiHanhChinhVN/master/data.json'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      final city = data.firstWhere((item) => item['Name'] == cityName,
          orElse: () => null);
      if (city != null) {
        setState(() {
          districts = city['Districts']
              .map<String>((item) => item['Name'].toString())
              .toList();
          selectedDistrict = null; // Reset selectedDistrict when city changes
          selectedWard = null; // Reset selectedWard when city changes
        });
      }
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<void> fetchWardData(String cityName, String districtName) async {
    final response = await http.get(Uri.parse(
        'https://raw.githubusercontent.com/kenzouno1/DiaGioiHanhChinhVN/master/data.json'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      final city = data.firstWhere((item) => item['Name'] == cityName,
          orElse: () => null);
      if (city != null) {
        final district = city['Districts'].firstWhere(
            (item) => item['Name'] == districtName,
            orElse: () => null);
        if (district != null) {
          setState(() {
            wards = district['Wards']
                .map<String>((item) => item['Name'].toString())
                .toList();
            selectedWard = null; // Reset selectedWard when district changes
          });
        }
      }
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: const Text(
          'Thêm địa chỉ',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
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
        child: Column(
          children: <Widget>[
            const SizedBox(
              height: 20,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const Row(
                children: [
                  Text(
                    'Họ và tên người liên hệ',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(width: 4),
                  Text(
                    '*',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.red),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  hintText: 'Họ và tên người liên hệ',
                ),
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const Row(
                children: [
                  Text(
                    'Số điện thoại',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(width: 4),
                  Text(
                    '*',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.red),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  hintText: 'Số điện thoại',
                ),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const Row(
                children: [
                  Text(
                    'Chọn tỉnh/ thành phố',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(width: 4),
                  Text(
                    '*',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.red),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: selectedCity,
                  onChanged: (newValue) {
                    setState(() {
                      selectedCity = newValue;
                      fetchDistrictData(
                          selectedCity!); // Fetch districts for the new city
                    });
                  },
                  items: cities.map((city) {
                    return DropdownMenuItem<String>(
                      value: city,
                      child: Text(city),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const Row(
                children: [
                  Text(
                    'Chọn quận/ huyện',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(width: 4),
                  Text(
                    '*',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.red),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: selectedDistrict,
                  onChanged: (newValue) {
                    setState(() {
                      selectedDistrict = newValue;
                      fetchWardData(selectedCity!,
                          selectedDistrict!); // Fetch wards for the new district
                    });
                  },
                  items: districts.map((district) {
                    return DropdownMenuItem<String>(
                      value: district,
                      child: Text(district),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const Row(
                children: [
                  Text(
                    'Chọn phường/ xã',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(width: 4),
                  Text(
                    '*',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.red),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: selectedWard,
                  onChanged: (newValue) {
                    setState(() {
                      selectedWard = newValue;
                    });
                  },
                  items: wards.map((ward) {
                    return DropdownMenuItem<String>(
                      value: ward,
                      child: Text(ward),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const Row(
                children: [
                  Text(
                    'Địa chỉ cụ thể',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(width: 4),
                  Text(
                    '*',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.red),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: addressController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  hintText: 'Địa chỉ cụ thể',
                ),
              ),
            ),
            Container(
              child: ListTile(
                title: const Text(
                  'Đặt làm địa chỉ mặc định',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                trailing: Switch(
                  value: isDefault,
                  onChanged: (value) {
                    setState(() {
                      isDefault = value;
                    });
                  },
                  activeColor: Colors.green,
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
        child: ElevatedButton(
          style: ButtonStyle(
            shape: MaterialStateProperty.all(RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            )),
            backgroundColor: MaterialStateProperty.all(Themes.gradientLightClr),
          ),
          onPressed: () {
            if (nameController.text.isNotEmpty &&
                phoneController.text.isNotEmpty &&
                selectedCity != null &&
                selectedDistrict != null &&
                selectedWard != null &&
                addressController.text.isNotEmpty) {
              String currentUserId = FirebaseAuth.instance.currentUser!.uid;
              bool isDefaultAddress = isDefault;
              FirebaseFirestore.instance.collection('addresses').add({
                'userId': currentUserId,
                'name': nameController.text,
                'phone': phoneController.text,
                'fullAddress':
                    '${addressController.text}, $selectedWard,$selectedDistrict,$selectedCity',
                'isDefault': isDefaultAddress,
              }).then((value) {
                print('Address added successfully!');
                return FirebaseFirestore.instance
                    .collection('addresses')
                    .doc(value.id)
                    .get();
              }).then((newAddress) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PurchaseScreen(
                      address: newAddress,
                    ),
                  ),
                );
              }).catchError((error) {
                print('Failed to add address: $error');
              });
            } else {
              print('Please fill in all required fields');
            }
          },
          child: const Text(
            'Lưu địa chỉ này',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
