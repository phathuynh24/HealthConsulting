import 'package:assist_health/others/methods.dart';
import 'package:assist_health/others/theme.dart';
import 'package:assist_health/ui/user_screens/register_call_step3.dart';
import 'package:flutter/material.dart';

class RegisterCallStep2 extends StatefulWidget {
  const RegisterCallStep2({super.key});

  @override
  State<RegisterCallStep2> createState() => _RegisterCallStep2();
}

class _RegisterCallStep2 extends State<RegisterCallStep2> {
  final List<String> _specialties = ['Sản phụ khoa'];

  bool _isVisibleInformation = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Themes.backgroundClr,
      appBar: AppBar(
        toolbarHeight: 50,
        title: const Text('Xác nhận thông tin'),
        titleTextStyle: const TextStyle(fontSize: 16),
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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(45),
          child: Container(
            height: 45,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            width: double.infinity,
            color: Colors.white,
            child: Container(
              color: Colors.blueAccent.withOpacity(0.1),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.greenAccent.shade700,
                      ),
                      child: const Text(
                        '1',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Text(
                      'Chọn lịch tư vấn',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.greenAccent.shade700,
                      ),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    const Icon(
                      Icons.arrow_right_alt_outlined,
                      size: 30,
                      color: Colors.blueGrey,
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blueAccent.shade700,
                      ),
                      child: const Text(
                        '2',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Text(
                      'Xác nhận',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.blueAccent.shade700,
                      ),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    const Icon(
                      Icons.arrow_right_alt_outlined,
                      size: 30,
                      color: Colors.blueGrey,
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blueGrey,
                      ),
                      child: const Text(
                        '3',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    const Text(
                      'Thanh toán',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.blueGrey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height - 220,
          color: Colors.blueAccent.withOpacity(0.1),
          child: Column(
            children: [
              // Thông tin đăng ký
              Container(
                margin: const EdgeInsets.only(
                  left: 15,
                  top: 20,
                  bottom: 5,
                ),
                child: const Row(
                  children: [
                    Text(
                      'THÔNG TIN ĐĂNG KÝ',
                      style: TextStyle(
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(
                              right: 15,
                            ),
                            child: SizedBox(
                              width: 70,
                              height: 70,
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
                                      getAbbreviatedName('HAHAHA AHHAHA'),
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
                          ),
                          SizedBox(
                            width: 265,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Thạc sĩ, Bác sĩ',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                    height: 1.5,
                                  ),
                                ),
                                const Text(
                                  'Nguyễn Văn Á',
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontSize: 15,
                                    height: 1.4,
                                  ),
                                ),
                                Text(
                                  'Chuyên khoa: ${_getAllOfSpecialties()}',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      thickness: 1,
                      color: Colors.grey.shade100,
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Giờ tư vấn',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.grey,
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  '08:00 - 08:15',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Ngày tư vấn',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.grey,
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  'CN 10/12/2023',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 15),
                      child: Text(
                        'Buổi sáng',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.greenAccent.shade700,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isVisibleInformation = !_isVisibleInformation;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Row(children: [
                          const Text(
                            'THÔNG TIN BỆNH NHÂN',
                            style: TextStyle(
                                fontSize: 13,
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
                          )),
                          Icon(
                            (_isVisibleInformation)
                                ? Icons.keyboard_arrow_down_rounded
                                : Icons.keyboard_arrow_up_rounded,
                            size: 25,
                            color: Colors.grey,
                          ),
                        ]),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Visibility(
                      visible: _isVisibleInformation,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Họ và tên',
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey,
                                              fontWeight: FontWeight.w400),
                                        ),
                                        SizedBox(height: 6),
                                        Text(
                                          'Huỳnh Tiến Phát',
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.black,
                                              fontWeight: FontWeight.w400),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Giới tính',
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey,
                                              fontWeight: FontWeight.w400),
                                        ),
                                        SizedBox(height: 6),
                                        Text(
                                          'Nam',
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.black,
                                              fontWeight: FontWeight.w400),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Số điện thoại',
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey,
                                              fontWeight: FontWeight.w400),
                                        ),
                                        SizedBox(height: 6),
                                        Text(
                                          '0362309724',
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.black,
                                              fontWeight: FontWeight.w400),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Ngày sinh',
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey,
                                              fontWeight: FontWeight.w400),
                                        ),
                                        SizedBox(height: 6),
                                        Text(
                                          '24/09/2003',
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.black,
                                              fontWeight: FontWeight.w400),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 20),
                            ]),
                      ),
                    ),
                  ],
                ),
              ),

              // Chi tiết thanh toán
              Container(
                margin: const EdgeInsets.only(
                  left: 15,
                  top: 20,
                  bottom: 5,
                ),
                child: const Row(
                  children: [
                    Text(
                      'CHI TIẾT THANH TOÁN',
                      style: TextStyle(
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15)),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Phí khám',
                            style: TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                                fontWeight: FontWeight.w400),
                          ),
                          SizedBox(height: 6),
                          Text(
                            '120.000 vnđ',
                            style: TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                                fontWeight: FontWeight.w400),
                          ),
                        ],
                      ),
                      SizedBox(height: 6),
                      Divider(
                        thickness: 1,
                        color: Colors.grey.shade100,
                      ),
                      SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Phí tiện ích',
                            style: TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                                fontWeight: FontWeight.w400),
                          ),
                          SizedBox(height: 6),
                          Text(
                            '995 vnđ',
                            style: TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                                fontWeight: FontWeight.w400),
                          ),
                        ],
                      ),
                      SizedBox(height: 6),
                      Divider(
                        thickness: 1,
                        color: Colors.grey.shade100,
                      ),
                      SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Tổng thanh toán',
                            style: TextStyle(
                                fontSize: 15,
                                color: Colors.black87,
                                fontWeight: FontWeight.w500),
                          ),
                          SizedBox(height: 6),
                          Text(
                            '120.995 vnđ',
                            style: TextStyle(
                                fontSize: 15,
                                color: Colors.black87,
                                fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ]),
              )
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        height: 150,
        padding: const EdgeInsets.symmetric(
          vertical: 8,
          horizontal: 15,
        ),
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Colors.blueGrey,
              width: 0.2,
            ),
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 6, bottom: 10),
              child: Text(
                'Hiện tại chỉ có thể thanh toán bằng cách quét mã thanh toán sau khi thực hiện xác nhận đăng ký',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  height: 1.3,
                  wordSpacing: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tổng',
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 6),
                  Text(
                    '120.995 vnđ',
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 8,
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const RegisterCallStep3()));
              },
              child: Container(
                padding: const EdgeInsets.all(13),
                margin: const EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(
                  color: Themes.gradientDeepClr,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'Xác nhận',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
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
