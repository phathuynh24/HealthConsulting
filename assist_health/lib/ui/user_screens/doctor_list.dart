import 'package:assist_health/others/methods.dart';
import 'package:assist_health/others/theme.dart';
import 'package:assist_health/ui/user_screens/doctor_detail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class DoctorListScreen extends StatefulWidget {
  const DoctorListScreen({super.key});

  @override
  State<DoctorListScreen> createState() => _DoctorListScreenState();
}

class _DoctorListScreenState extends State<DoctorListScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();

  final List<String> _statusOptions = ['Trực tuyến', 'Cần đặt lịch', 'Tất cả'];
  String? _selectedStatusRadio;
  String? _selectedStatus;

  final List<String> _specialtyOptions = [
    'Tổng quát',
    'Nhi khoa',
    'Sản - Phụ khoa',
    'Tâm lý',
    'Da liễu',
    'Răng - Hàm - Mặt',
    'Tai - Mũi - Họng',
  ];
  String? _selectedSpecialtyRadio;
  String? _selectedSpecialty;

  @override
  void initState() {
    _selectedStatus = 'Tất cả';
    _selectedStatusRadio = _selectedStatus;

    _selectedSpecialty = 'Tất cả';
    _selectedSpecialtyRadio = '';
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void setSelectedStatus(String value) {
    setState(() {
      _selectedStatus = value;
    });
  }

  void setSelectedSpecialty(String value) {
    setState(() {
      _selectedSpecialty = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Themes.backgroundClr,
      appBar: AppBar(
        toolbarHeight: 70,
        title: Container(
          decoration: BoxDecoration(
            color: Colors.blueGrey.shade800,
            borderRadius: BorderRadius.circular(30),
          ),
          child: TextFormField(
            controller: _searchController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
                contentPadding: const EdgeInsets.all(15),
                hintText: 'Tên bác sĩ',
                hintStyle: const TextStyle(color: Colors.white70),
                prefixIcon: const Icon(Icons.search, color: Colors.white70),
                border: InputBorder.none,
                suffixIconConstraints:
                    const BoxConstraints(maxHeight: 40, maxWidth: 40),
                suffixIcon: GestureDetector(
                  onTap: () {
                    setState(() {
                      _searchController.text = '';
                    });
                  },
                  child: Container(
                    width: 20,
                    height: 20,
                    margin: const EdgeInsets.only(
                      right: 10,
                    ),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white70,
                    ),
                    child: Center(
                      child: Icon(
                        Icons.clear,
                        size: 18,
                        color: Colors.blueGrey.shade700,
                      ),
                    ),
                  ),
                )),
          ),
        ),
        centerTitle: true,
        elevation: 0.5,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Themes.gradientDeepClr, Themes.gradientLightClr],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(45),
          child: Container(
            height: 45,
            width: double.infinity,
            color: Colors.white,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      _showStatusBottomSheet(context);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(
                        left: 10,
                      ),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.black45,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          (_selectedStatus != _statusOptions[2])
                              ? DotsIndicator(
                                  dotsCount: 1,
                                  decorator: DotsDecorator(
                                    activeColor:
                                        (_selectedStatus == _statusOptions[0])
                                            ? Colors.green
                                            : Colors.amber,
                                    spacing: const EdgeInsets.symmetric(
                                        horizontal: 0),
                                  ),
                                )
                              : const SizedBox.shrink(),
                          const SizedBox(
                            width: 5,
                          ),
                          const Text(
                            'Trạng thái: ',
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            _selectedStatus!,
                            style: const TextStyle(
                              color: Colors.black54,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      _showSpecialtyBottomSheet(context);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(
                        left: 5,
                        right: 10,
                      ),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.black45,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            FontAwesomeIcons.starOfLife,
                            size: 13,
                            color: Themes.gradientLightClr,
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          const Text(
                            'Chuyên khoa: ',
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            _selectedSpecialty!,
                            style: const TextStyle(
                              color: Colors.black54,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('users')
            .where('role', isEqualTo: 'doctor')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Đã xảy ra lỗi: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }

          // Lấy danh sách các documents từ snapshot
          final List<DocumentSnapshot> users = snapshot.data!.docs;

          return Container(
            color: Colors.blueAccent.withOpacity(0.1),
            child: ListView.builder(
              itemCount: 20,
              itemBuilder: (context, index) {
                // Lấy dữ liệu của mỗi document
                final userData =
                    users[index % 3].data() as Map<String, dynamic>;
                final username = userData['name'] as String;
                final email = userData['email'] as String;

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const DoctorDetailScreen()));
                  },
                  child: Container(
                    height: 210,
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: const BoxDecoration(color: Colors.white),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              margin: const EdgeInsets.only(
                                right: 10,
                              ),
                              width: 105,
                              height: 105,
                              child: Stack(
                                children: [
                                  SizedBox(
                                    width: 100,
                                    height: 100,
                                    child: ClipOval(
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Themes.gradientDeepClr,
                                              Themes.gradientLightClr
                                            ],
                                            begin: Alignment.bottomCenter,
                                            end: Alignment.topCenter,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            getAbbreviatedName(username),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 30,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                      top: 0,
                                      right: 0,
                                      child: DotsIndicator(
                                        dotsCount: 1,
                                        decorator: DotsDecorator(
                                          activeColor:
                                              Colors.greenAccent.shade700,
                                          activeSize: const Size(20, 20),
                                        ),
                                      )),
                                  Positioned(
                                      bottom: 0,
                                      right: 0,
                                      left: 0,
                                      child: Container(
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 35,
                                        ),
                                        padding: const EdgeInsets.all(2),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.black.withOpacity(0.2),
                                              blurRadius: 5,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.star,
                                              color: Colors.amber,
                                              size: 15,
                                            ),
                                            Text(
                                              '5',
                                              style: TextStyle(
                                                fontSize: 13,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: 270,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    username,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 15,
                                      height: 1.5,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text(
                                    username,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 15,
                                      height: 1.5,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text(
                                    username,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 15,
                                      height: 1.5,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text(
                                    'Chuyên khoa: $username',
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 15,
                                      height: 1.5,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            const Text(
                              'Phí tư vấn: ',
                              style: TextStyle(
                                fontSize: 15,
                              ),
                            ),
                            Text(
                              '120.000 vnđ/15 phút',
                              style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.greenAccent.shade700,
                                  fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Expanded(
                              child: Container(
                                height: 50,
                                margin: const EdgeInsets.only(
                                  right: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.greenAccent.shade700,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Center(
                                  child: Text(
                                    'Gọi video ngay',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                height: 50,
                                margin: const EdgeInsets.only(
                                  left: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: Themes.gradientDeepClr,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Center(
                                  child: Text(
                                    'Đặt lịch gọi',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _showStatusBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return Container(
            color: Colors.transparent,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 5,
                  width: 50,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2.5),
                    color: Colors.grey.shade300,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 15,
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Stack(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            'Lọc trạng thái',
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(
                            height: 18,
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              'Tùy chọn hiển thị danh sách các bác sĩ theo trạng thái sẽ giúp bạn dễ dàng tìm hiểu và đặt lịch tư vấn',
                              style: TextStyle(fontSize: 13),
                            ),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.9,
                            margin: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.grey.shade300,
                                  width: 1,
                                )),
                            child: Column(
                              children: [
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      _selectedStatusRadio = _statusOptions[0];
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    child: Row(
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                DotsIndicator(
                                                  dotsCount: 1,
                                                  decorator:
                                                      const DotsDecorator(
                                                    activeColor: Colors.green,
                                                  ),
                                                ),
                                                Text(
                                                  _statusOptions[0],
                                                  style: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(
                                              height: 9,
                                            ),
                                            const SizedBox(
                                              width: 285,
                                              child: Text(
                                                'Danh sách bác sĩ đang trực tuyến, bạn có thể gọi ngay',
                                                softWrap: true,
                                              ),
                                            )
                                          ],
                                        ),
                                        const Spacer(),
                                        Radio(
                                          value: _statusOptions[0],
                                          groupValue: _selectedStatusRadio,
                                          onChanged: (value) {
                                            setState(() {
                                              _selectedStatusRadio = value;
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Divider(
                                  thickness: 1,
                                  color: Colors.grey.shade300,
                                ),
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      _selectedStatusRadio = _statusOptions[1];
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    child: Row(
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                DotsIndicator(
                                                  dotsCount: 1,
                                                  decorator:
                                                      const DotsDecorator(
                                                    activeColor: Colors.amber,
                                                  ),
                                                ),
                                                Text(
                                                  _statusOptions[1],
                                                  style: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(
                                              height: 9,
                                            ),
                                            const SizedBox(
                                              width: 285,
                                              child: Text(
                                                  'Danh sách bác sĩ bạn cần đặt lịch trước khi gọi'),
                                            )
                                          ],
                                        ),
                                        const Spacer(),
                                        Radio(
                                          value: _statusOptions[1],
                                          groupValue: _selectedStatusRadio,
                                          onChanged: (value) {
                                            setState(() {
                                              _selectedStatusRadio = value;
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Divider(
                                  thickness: 1,
                                  color: Colors.grey.shade300,
                                ),
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      _selectedStatusRadio = _statusOptions[2];
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          _statusOptions[2],
                                          style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500),
                                        ),
                                        const Spacer(),
                                        Radio(
                                          value: _statusOptions[2],
                                          groupValue: _selectedStatusRadio,
                                          onChanged: (value) {
                                            setState(() {
                                              _selectedStatusRadio = value;
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setSelectedStatus(_selectedStatusRadio!);
                              Navigator.of(context).pop();
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              width: double.infinity,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Themes.gradientDeepClr,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Center(
                                child: Text(
                                  'Áp dụng',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                      Positioned(
                        top: 0,
                        right: 15,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: const Icon(
                            Icons.close,
                            size: 24,
                            color: Colors.grey,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          );
        });
      },
    );
  }

  void _showSpecialtyBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return Container(
            color: Colors.transparent,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 5,
                  width: 50,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2.5),
                    color: Colors.grey.shade300,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 15,
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Stack(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            'Lọc chuyên khoa tư vấn',
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(
                            height: 18,
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              'Tùy chọn hiển thị danh sách các bác sĩ theo chuyên khoa tư vấn',
                              style: TextStyle(fontSize: 13),
                            ),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.9,
                            margin: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.grey.shade300,
                                  width: 1,
                                )),
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: _specialtyOptions.length,
                              itemBuilder: (BuildContext context, int index) {
                                String option =
                                    'Tư vấn ${_specialtyOptions[index]}';
                                return InkWell(
                                  onTap: () {
                                    setState(() {
                                      _selectedSpecialtyRadio = option;
                                    });
                                  },
                                  child: Column(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 5,
                                        ),
                                        child: Row(
                                          children: [
                                            DotsIndicator(
                                              dotsCount: 1,
                                              decorator: const DotsDecorator(
                                                activeColor: Colors.green,
                                              ),
                                            ),
                                            Text(
                                              'Tư vấn $option',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const Spacer(),
                                            Radio(
                                              value: option,
                                              groupValue:
                                                  _selectedSpecialtyRadio,
                                              onChanged: (value) {
                                                setState(() {
                                                  _selectedSpecialtyRadio =
                                                      value;
                                                });
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (index != _specialtyOptions.length - 1)
                                        Divider(
                                          thickness: 1,
                                          height: 2,
                                          color: Colors.grey.shade300,
                                        )
                                      else
                                        const SizedBox.shrink(),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedSpecialtyRadio = 'Tất cả';
                                    });
                                    setSelectedSpecialty(
                                        _selectedSpecialtyRadio!);
                                    Navigator.of(context).pop();
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(
                                      left: 20,
                                      right: 10,
                                    ),
                                    width: double.infinity,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade300,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Center(
                                      child: Text(
                                        'Xóa bộ lọc',
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    setSelectedSpecialty(
                                        _selectedSpecialtyRadio!);
                                    Navigator.of(context).pop();
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(
                                      left: 10,
                                      right: 20,
                                    ),
                                    width: double.infinity,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: Themes.gradientDeepClr,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Center(
                                      child: Text(
                                        'Áp dụng',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                      Positioned(
                        top: 0,
                        right: 15,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: const Icon(
                            Icons.close,
                            size: 24,
                            color: Colors.grey,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          );
        });
      },
    );
  }
}
