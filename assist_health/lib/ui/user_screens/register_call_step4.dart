import 'package:assist_health/others/methods.dart';
import 'package:assist_health/others/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RegisterCallStep4 extends StatefulWidget {
  const RegisterCallStep4({super.key});

  @override
  State<RegisterCallStep4> createState() => _RegisterCallStep4();
}

class _RegisterCallStep4 extends State<RegisterCallStep4> {
  final List<String> _specialties = ['Sản phụ khoa'];
  bool _isVisibleInformation = true;
  bool _isVisiblePayment = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Themes.backgroundClr,
      appBar: AppBar(
        toolbarHeight: 50,
        title: const Text('Nhận lịch hẹn'),
        titleTextStyle: const TextStyle(fontSize: 16),
        centerTitle: true,
        automaticallyImplyLeading: false,
        elevation: 0,
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
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          color: Colors.blueAccent.withOpacity(0.1),
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(
                children: [
                  Container(
                    color: Colors.transparent,
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          margin: EdgeInsets.only(
                            top: 40,
                          ),
                          padding: EdgeInsets.only(
                            top: 40,
                            bottom: 15,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'Đã đặt lịch',
                                style: TextStyle(
                                  color: Colors.greenAccent.shade400,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              Text(
                                '09:15:27 12/12/2023',
                                style: TextStyle(
                                  color: Colors.blueGrey,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.greenAccent.shade400.withOpacity(0.2),
                      ),
                      child: Icon(
                        Icons.check_circle,
                        color: Colors.greenAccent.shade400,
                        size: 60,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                color: Colors.transparent,
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(
                        10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'STT',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.blueGrey,
                            ),
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Text(
                            '9',
                            style: TextStyle(
                              fontSize: 70,
                              color: Colors.greenAccent.shade400,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Divider(
                            height: 20,
                            indent: 10,
                            endIndent: 6,
                            thickness: 1,
                            color: Colors.grey.shade300,
                          ),
                          Container(
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Thông tin lịch khám
                                Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Row(
                                    children: [
                                      Container(
                                        margin: const EdgeInsets.only(
                                          right: 15,
                                        ),
                                        child: SizedBox(
                                          width: 60,
                                          height: 60,
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
                                                  getAbbreviatedName(
                                                      'HAHAHA AHHAHA'),
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 25,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 255,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Thạc sĩ, Bác sĩ',
                                              style: TextStyle(
                                                color: Colors.black87,
                                                fontSize: 15,
                                                height: 1.5,
                                              ),
                                            ),
                                            const Text(
                                              'Nguyễn Văn Á',
                                              style: TextStyle(
                                                color: Colors.black87,
                                                fontSize: 16,
                                                height: 1.4,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 7,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      SizedBox(
                                          width: 100,
                                          child: Text(
                                            'Mã lịch khám',
                                            style: TextStyle(
                                              fontSize: 15,
                                            ),
                                          )),
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () {
                                            final data = ClipboardData(
                                                text: 'MLK2312120021');
                                            Clipboard.setData(data);
                                            // Hiển thị thông báo hoặc thực hiện các tác vụ khác
                                            ScaffoldMessenger.of(context)
                                                .hideCurrentSnackBar();
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                  backgroundColor: Colors
                                                      .greenAccent.shade700,
                                                  content: Text(
                                                      'Mã lịch khám đã được sao chép')),
                                            );
                                          },
                                          child: Text(
                                            'MLK2312120021',
                                            style: TextStyle(
                                              fontSize: 15,
                                            ),
                                            textAlign: TextAlign.right,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Icon(
                                        Icons.content_copy,
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 7,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      SizedBox(
                                          width: 100,
                                          child: Text(
                                            'Ngày khám',
                                            style: TextStyle(
                                              fontSize: 15,
                                            ),
                                          )),
                                      Expanded(
                                          child: Text(
                                        'CN, 31/12/2023',
                                        style: TextStyle(
                                          fontSize: 15,
                                        ),
                                        textAlign: TextAlign.right,
                                      ))
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 7,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      SizedBox(
                                          width: 100,
                                          child: Text(
                                            'Giờ khám',
                                            style: TextStyle(
                                              fontSize: 15,
                                            ),
                                          )),
                                      Expanded(
                                          child: Text(
                                        '10:45 - 11:00 (Buổi sáng)',
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.greenAccent.shade400,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        textAlign: TextAlign.right,
                                      ))
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 7,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      SizedBox(
                                          width: 100,
                                          child: Text(
                                            'Chuyên khoa',
                                            style: TextStyle(
                                              fontSize: 15,
                                            ),
                                          )),
                                      Expanded(
                                          child: Text(
                                        _getAllOfSpecialties(),
                                        style: TextStyle(
                                          fontSize: 15,
                                        ),
                                        textAlign: TextAlign.right,
                                      ))
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),

                                // Thông tin bệnh nhân
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _isVisibleInformation =
                                          !_isVisibleInformation;
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    child: Row(children: [
                                      const Text(
                                        'THÔNG TIN BỆNH NHÂN',
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey,
                                            fontWeight: FontWeight.w500),
                                      ),
                                      Expanded(
                                        child: Divider(
                                          height: 20,
                                          indent: 10,
                                          endIndent: 6,
                                          thickness: 1,
                                          color: Colors.grey.shade300,
                                        ),
                                      ),
                                      Icon(
                                        (_isVisibleInformation)
                                            ? Icons.keyboard_arrow_down_rounded
                                            : Icons.keyboard_arrow_up_rounded,
                                        size: 27,
                                        color: Colors.grey.shade400,
                                      ),
                                    ]),
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Visibility(
                                  visible: _isVisibleInformation,
                                  child: Container(
                                    child: const Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 7,
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              SizedBox(
                                                  width: 100,
                                                  child: Text(
                                                    'Họ và tên',
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                    ),
                                                  )),
                                              Expanded(
                                                  child: Text(
                                                'Huỳnh Tiến Phát',
                                                style: TextStyle(
                                                  fontSize: 15,
                                                ),
                                                textAlign: TextAlign.right,
                                              ))
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 7,
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              SizedBox(
                                                  width: 100,
                                                  child: Text(
                                                    'Ngày sinh',
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                    ),
                                                  )),
                                              Expanded(
                                                  child: Text(
                                                '24/09/2003',
                                                style: TextStyle(
                                                  fontSize: 15,
                                                ),
                                                textAlign: TextAlign.right,
                                              ))
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 7,
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              SizedBox(
                                                  width: 100,
                                                  child: Text(
                                                    'Giới tính',
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                    ),
                                                  )),
                                              Expanded(
                                                  child: Text(
                                                'Nam',
                                                style: TextStyle(
                                                  fontSize: 15,
                                                ),
                                                textAlign: TextAlign.right,
                                              ))
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 7,
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              SizedBox(
                                                  width: 100,
                                                  child: Text(
                                                    'Số điện thoại',
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                    ),
                                                  )),
                                              Expanded(
                                                  child: Text(
                                                '0362309724',
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  letterSpacing: 1.1,
                                                ),
                                                textAlign: TextAlign.right,
                                              ))
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Center(
                                          child: Text(
                                            'Xem chi tiết',
                                            style: TextStyle(
                                              color: Themes.gradientDeepClr,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),

                                // Thông tin thanh toán
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _isVisiblePayment = !_isVisiblePayment;
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    child: Row(children: [
                                      const Text(
                                        'THÔNG TIN THANH TOÁN',
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey,
                                            fontWeight: FontWeight.w500),
                                      ),
                                      Expanded(
                                        child: Divider(
                                          height: 20,
                                          indent: 10,
                                          endIndent: 6,
                                          thickness: 1,
                                          color: Colors.grey.shade300,
                                        ),
                                      ),
                                      Icon(
                                        (_isVisibleInformation)
                                            ? Icons.keyboard_arrow_down_rounded
                                            : Icons.keyboard_arrow_up_rounded,
                                        size: 27,
                                        color: Colors.grey.shade400,
                                      ),
                                    ]),
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Visibility(
                                  visible: _isVisiblePayment,
                                  child: Container(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 7,
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              SizedBox(
                                                  width: 100,
                                                  child: Text(
                                                    'Mã thanh toán',
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                    ),
                                                  )),
                                              Expanded(
                                                child: GestureDetector(
                                                  onTap: () {
                                                    final data = ClipboardData(
                                                        text: 'MLK2312120022');
                                                    Clipboard.setData(data);
                                                    // Hiển thị thông báo hoặc thực hiện các tác vụ khác
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .hideCurrentSnackBar();
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      SnackBar(
                                                          backgroundColor:
                                                              Colors.greenAccent
                                                                  .shade700,
                                                          content: Text(
                                                              'Mã thanh toán đã được sao chép')),
                                                    );
                                                  },
                                                  child: Text(
                                                    'MLK2312120022',
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                    ),
                                                    textAlign: TextAlign.right,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              Icon(
                                                Icons.content_copy,
                                                size: 20,
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 7,
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              SizedBox(
                                                  width: 100,
                                                  child: Text(
                                                    'Trạng thái',
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                    ),
                                                  )),
                                              Expanded(
                                                  child: Text(
                                                'Chưa thanh toán',
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.orange,
                                                ),
                                                textAlign: TextAlign.right,
                                              ))
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 7,
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              SizedBox(
                                                  width: 100,
                                                  child: Text(
                                                    'Phương thức',
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                    ),
                                                  )),
                                              Expanded(
                                                  child: Text(
                                                'Quét mã QR Code',
                                                style: TextStyle(
                                                  fontSize: 15,
                                                ),
                                                textAlign: TextAlign.right,
                                              ))
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 7,
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              SizedBox(
                                                  width: 100,
                                                  child: Text(
                                                    'Phí tư vấn',
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                    ),
                                                  )),
                                              Expanded(
                                                  child: Text(
                                                '150.00 VNĐ',
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  letterSpacing: 1.1,
                                                ),
                                                textAlign: TextAlign.right,
                                              ))
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _getAllOfSpecialties() {
    String allOfSpecialties = '';
    for (int i = 0; i < _specialties.length; i++) {
      if (i == 0) {
        allOfSpecialties = _specialties[i];
      } else {
        allOfSpecialties = '$allOfSpecialties, ${_specialties[i]}';
      }
    }
    return allOfSpecialties;
  }
}
