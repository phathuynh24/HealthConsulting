import 'package:assist_health/src/models/doctor/doctor_info.dart';
import 'package:assist_health/src/others/methods.dart';
import 'package:assist_health/src/others/theme.dart';
import 'package:assist_health/src/presentation/screens/user_screens/doctor_detail.dart';
import 'package:assist_health/src/presentation/screens/user_screens/register_call_now_step1.dart';
import 'package:assist_health/src/presentation/screens/user_screens/register_call_step1.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

// ignore: must_be_immutable
class DoctorListScreen extends StatefulWidget {
  String? filterSpecialty = '';
  DoctorListScreen({super.key, this.filterSpecialty});

  @override
  State<DoctorListScreen> createState() => _DoctorListScreenState();
}

class _DoctorListScreenState extends State<DoctorListScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<String> _statusOptions = ['Trực tuyến', 'Cần đặt lịch', 'Tất cả'];
  String? _selectedStatusRadio;
  String? _selectedStatus;

  final List<String> _specialtyOptions = [
    "Tay mũi họng",
    "Bệnh nhiệt đới",
    "Nội thần kinh",
    "Mắt",
    "Nha khoa",
    "Chấn thương chỉnh hình",
    "Tim mạch",
    "Tiêu hóa",
    "Hô hấp",
    "Huyết học",
    "Nội tiết",
  ];
  String? _selectedSpecialtyRadio;
  String? _selectedSpecialty;
  String? _searchName;

  @override
  void initState() {
    super.initState();
    _selectedStatus = 'Tất cả';
    _selectedStatusRadio = _selectedStatus;

    if (widget.filterSpecialty != null && widget.filterSpecialty != '') {
      setSelectedSpecialty(widget.filterSpecialty!);
    } else {
      setSelectedSpecialty('Tất cả');
    }

    _searchName = '';
  }

  void setSelectedStatus(String value) {
    setState(() {
      _selectedStatus = value;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void setSelectedSpecialty(String value) {
    setState(() {
      _selectedSpecialty = value;
      _selectedSpecialtyRadio = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Themes.backgroundClr,
      appBar: AppBar(
        foregroundColor: Colors.white,
        toolbarHeight: 55,
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.blueGrey.shade800.withOpacity(0.7),
            borderRadius: BorderRadius.circular(30),
          ),
          child: TextFormField(
            controller: _searchController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.all(10),
              hintText: 'Tên bác sĩ',
              hintStyle: const TextStyle(color: Colors.white70),
              prefixIcon: const Icon(
                Icons.search,
                color: Colors.white70,
                size: 22,
              ),
              border: InputBorder.none,
              suffixIconConstraints:
                  const BoxConstraints(maxHeight: 30, maxWidth: 30),
              suffixIcon: GestureDetector(
                onTap: () {
                  setState(() {
                    _searchName = '';
                    _searchController.text = _searchName!;
                  });
                },
                child: Container(
                  width: 18,
                  height: 18,
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
                      size: 16,
                      color: Colors.blueGrey.shade700,
                    ),
                  ),
                ),
              ),
            ),
            onChanged: (value) {
              setState(() {
                _searchName = value;
              });
            },
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
                          color: Colors.blueGrey,
                          width: 0.7,
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
                              color: Colors.blueGrey,
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            _selectedStatus!,
                            style: const TextStyle(
                              color: Colors.blueGrey,
                              fontWeight: FontWeight.w500,
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
                          color: Colors.blueGrey,
                          width: 0.7,
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
                              color: Colors.blueGrey,
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            _selectedSpecialty!,
                            style: const TextStyle(
                              color: Colors.blueGrey,
                              fontWeight: FontWeight.w500,
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
      body: StreamBuilder<List<DoctorInfo>>(
        stream: getInfoDoctors(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Đã xảy ra lỗi: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Lọc bỏ các bác sĩ có isDeleted = true
          List<DoctorInfo> activeDoctors = snapshot.data!
              .where((doctor) => doctor.isDeleted == false)
              .toList();

          List<DoctorInfo> filterDoctorWithStatus;
          String status = '';

          if (_selectedStatus == _statusOptions[0]) {
            status = 'online';
          }

          if (_selectedStatus == _statusOptions[1]) {
            status = 'offline';
          }

          if (_selectedStatus == _statusOptions[2]) {
            filterDoctorWithStatus = activeDoctors.toList();

            filterDoctorWithStatus.sort((a, b) {
              if (a.status == 'online' && b.status == 'offline') {
                return -1; // Sắp xếp a lên trước b
              } else if (a.status == 'offline' && b.status == 'online') {
                return 1; // Sắp xếp b lên trước a
              } else {
                return 0; // Giữ nguyên thứ tự
              }
            });
          } else {
            filterDoctorWithStatus = activeDoctors
                .where((doctor) => doctor.status == status)
                .toList();
          }

          if (filterDoctorWithStatus.isEmpty) {
            return Center(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                height: 500,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/empty-box.png',
                      width: 250,
                      height: 250,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Bạn chưa có lịch khám ở mục này',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Lịch khám của bạn sẽ được hiển thị tại đây.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blueGrey,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          List<DoctorInfo> filterDoctorWithSpecialty = [];
          if (_selectedSpecialtyRadio == 'Tất cả') {
            filterDoctorWithSpecialty = filterDoctorWithStatus;
          } else {
            filterDoctorWithSpecialty = filterDoctorWithStatus
                .where(
                    (doctor) => doctor.specialty.contains(_selectedSpecialty))
                .toList();
          }

          if (filterDoctorWithSpecialty.isEmpty) {
            return Center(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                height: 500,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/empty-box.png',
                      width: 250,
                      height: 250,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Không có dữ liệu',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Vui lòng chọn trạng thái hoặc chuyên khoa khác',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blueGrey,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          List<DoctorInfo> filterDoctorWithName;
          if (_searchName!.trim() != '') {
            filterDoctorWithName = filterDoctorWithSpecialty
                .where((doctor) => doctor.name
                    .toLowerCase()
                    .contains(_searchName!.toLowerCase()))
                .toList();
          } else {
            filterDoctorWithName = filterDoctorWithSpecialty;
          }

          if (filterDoctorWithName.isEmpty) {
            return SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                height: 350,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Image.asset(
                      'assets/no_result_search_icon.png',
                      width: 250,
                      height: 250,
                      fit: BoxFit.contain,
                    ),
                    const Text(
                      'Không tìm thấy kết quả',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Rất tiếc, chúng tôi không tìm thấy kết quả mà bạn mong muốn, hãy thử lại xem sao.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return Container(
            color: Colors.blueAccent.withOpacity(0.1),
            child: ListView.builder(
              itemCount: filterDoctorWithName.length,
              itemBuilder: (context, index) {
                bool isOnline = filterDoctorWithName[index].status == 'online';
                DoctorInfo doctor = filterDoctorWithName[index];

                return Container(
                  margin:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                  padding: const EdgeInsets.only(
                    top: 10,
                    left: 10,
                    right: 10,
                    bottom: 5,
                  ),
                  decoration: const BoxDecoration(color: Colors.white),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      DoctorDetailScreen(doctorInfo: doctor)));
                        },
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(
                                    right: 10,
                                  ),
                                  width: 100,
                                  height: 100,
                                  child: Stack(
                                    children: [
                                      SizedBox(
                                        width: 90,
                                        height: 90,
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
                                            child: (doctor.imageURL != '')
                                                ? Image.network(doctor.imageURL,
                                                    fit: BoxFit.cover,
                                                    errorBuilder:
                                                        (BuildContext context,
                                                            Object exception,
                                                            StackTrace?
                                                                stackTrace) {
                                                    return const Center(
                                                      child: Icon(
                                                        FontAwesomeIcons
                                                            .userDoctor,
                                                        size: 80,
                                                        color: Colors.white,
                                                      ),
                                                    );
                                                  })
                                                : Center(
                                                    child: Text(
                                                      getAbbreviatedName(
                                                          doctor.name),
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 30,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                          top: 0,
                                          right: 0,
                                          child: Container(
                                            padding: const EdgeInsets.all(0.5),
                                            decoration: const BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.white),
                                            child: DotsIndicator(
                                              dotsCount: 1,
                                              decorator: DotsDecorator(
                                                activeColor: isOnline
                                                    ? Colors
                                                        .greenAccent.shade700
                                                    : Colors
                                                        .amberAccent.shade700,
                                                activeSize: const Size(15, 15),
                                              ),
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
                                                  color: Colors.black
                                                      .withOpacity(0.2),
                                                  blurRadius: 5,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                const Icon(
                                                  Icons.star,
                                                  color: Colors.amber,
                                                  size: 15,
                                                ),
                                                Text(
                                                  doctor.rating.toString(),
                                                  style: const TextStyle(
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
                                  width: 255,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        doctor.careerTitiles,
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 14,
                                          height: 1.5,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Text(
                                        doctor.name,
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 14,
                                          height: 1.5,
                                          fontWeight: FontWeight.w500,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      // Text(
                                      //   '${DateTime.now().year - doctor.graduationYear} năm kinh nghiệm',
                                      //   style: const TextStyle(
                                      //     color: Colors.black,
                                      //     fontSize: 14,
                                      //     height: 1.5,
                                      //     overflow: TextOverflow.ellipsis,
                                      //   ),
                                      // ),
                                      Row(
                                        children: [
                                          const Text(
                                            'Chuyên khoa: ',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 14,
                                              height: 1.5,
                                            ),
                                          ),
                                          SizedBox(
                                              height: 28,
                                              width: 148,
                                              child: ListView.builder(
                                                shrinkWrap: true,
                                                scrollDirection:
                                                    Axis.horizontal,
                                                itemCount:
                                                    doctor.specialty.length,
                                                itemBuilder: (context, index) {
                                                  final specialty =
                                                      doctor.specialty[index];
                                                  return Container(
                                                    margin: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 2),
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 9),
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20),
                                                      color: Colors.blueGrey
                                                          .withOpacity(0.1),
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                        specialty,
                                                        style: const TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 13,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w400),
                                                      ),
                                                    ),
                                                  );
                                                },
                                              )),
                                        ],
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
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  // '${NumberFormat("#,##0", "en_US").format(int.parse(doctor.serviceFee.toString()))} VNĐ/${doctor.consultingTime} phút',
                                  '${NumberFormat("#,##0", "en_US").format(int.parse(doctor.serviceFee.toString()))} VNĐ/15 phút',
                                  style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.greenAccent.shade700,
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // const SizedBox(
                      //   height: 10,
                      // ),
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.spaceAround,
                      //   children: [
                      //     Expanded(
                      //       child: GestureDetector(
                      //         onTap: () {
                      //           isOnline
                      //               ? Navigator.push(
                      //                   context,
                      //                   MaterialPageRoute(
                      //                       builder: (context) =>
                      //                           RegisterCallNowStep1(
                      //                             doctorInfo: doctor,
                      //                           )))
                      //               : showNotificationDialog(context);
                      //         },
                      //         child: Container(
                      //           height: 50,
                      //           margin: const EdgeInsets.only(
                      //             right: 5,
                      //           ),
                      //           decoration: BoxDecoration(
                      //             color: isOnline
                      //                 ? Colors.greenAccent.shade700
                      //                 : Colors.blueGrey.shade200,
                      //             borderRadius: BorderRadius.circular(10),
                      //           ),
                      //           child: const Center(
                      //             child: Text(
                      //               'Gọi ngay',
                      //               style: TextStyle(
                      //                 fontSize: 14,
                      //                 color: Colors.white,
                      //                 fontWeight: FontWeight.w500,
                      //               ),
                      //             ),
                      //           ),
                      //         ),
                      //       ),
                      //     ),
                      //     Expanded(
                      //       child: InkWell(
                      //         onTap: () {
                      //           Navigator.push(
                      //               context,
                      //               MaterialPageRoute(
                      //                   builder: (context) => RegisterCallStep1(
                      //                       isEdit: false,
                      //                       doctorInfo: doctor)));
                      //         },
                      //         child: Container(
                      //           height: 50,
                      //           margin: const EdgeInsets.only(
                      //             left: 5,
                      //           ),
                      //           decoration: BoxDecoration(
                      //             color: Themes.gradientDeepClr,
                      //             borderRadius: BorderRadius.circular(10),
                      //           ),
                      //           child: const Center(
                      //             child: Text(
                      //               'Đặt lịch',
                      //               style: TextStyle(
                      //                 fontSize: 14,
                      //                 color: Colors.white,
                      //                 fontWeight: FontWeight.w500,
                      //               ),
                      //             ),
                      //           ),
                      //         ),
                      //       ),
                      //     ),
                      //   ],
                      // )
                    ],
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
                            height: 600,
                            width: MediaQuery.of(context).size.width * 0.9,
                            margin: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.grey.shade300,
                                  width: 1,
                                )),
                            child: ListView.builder(
                              itemCount: _specialtyOptions.length,
                              itemBuilder: (BuildContext context, int index) {
                                String option = _specialtyOptions[index];
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
                                    setSelectedSpecialty('Tất cả');
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

  void showNotificationDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Thông báo'),
        content: const Text('Bác sĩ không trực tuyến, vui lòng thử lại sau.'),
        actions: [
          TextButton(
            child: const Text('Đồng ý'),
            onPressed: () {
              Navigator.of(context).pop(); // Đóng thông báo
            },
          ),
        ],
      ),
    );
  }
}
