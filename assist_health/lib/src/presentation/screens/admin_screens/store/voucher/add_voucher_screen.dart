import 'package:assist_health/src/others/theme.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class InvertedCircleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    var radius = 20.0;

    path.moveTo(radius, 0);
    path.lineTo(size.width - radius, 0);
    path.arcToPoint(
        Offset(
          size.width,
          radius,
        ),
        radius: Radius.circular(radius),
        clockwise: false);

    path.lineTo(size.width, size.height - radius);
    path.arcToPoint(Offset(size.width - radius, size.height),
        radius: Radius.circular(radius), clockwise: false);
    path.lineTo(radius, size.height);
    path.arcToPoint(Offset(0, size.height - radius),
        radius: Radius.circular(radius), clockwise: false);
    path.lineTo(0, radius);
    path.arcToPoint(Offset(radius, 0),
        radius: Radius.circular(radius), clockwise: false);

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class AddVoucherScreen extends StatefulWidget {
  const AddVoucherScreen({Key? key}) : super(key: key);

  @override
  _AddVoucherScreenState createState() => _AddVoucherScreenState();
}

class _AddVoucherScreenState extends State<AddVoucherScreen> {
  final _formKey = GlobalKey<FormState>();
  final _voucherCodeController = TextEditingController();
  final _discountController = TextEditingController();

  void createVoucher() async {
    if (_formKey.currentState!.validate()) {
      CollectionReference vouchers =
          FirebaseFirestore.instance.collection('vouchers');

      await vouchers
          .add({
            'voucherCode': _voucherCodeController.text,
            'discount': int.parse(_discountController.text),
            'createdAt': Timestamp.now(),
          })
          .then((value) => print("Voucher Added"))
          .catchError((error) => print("Failed to add voucher: $error"));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: const Text(
          'Thêm Voucher',
          style: TextStyle(fontSize: 20),
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Row(
                    children: [
                      const SizedBox(width: 16),
                      Flexible(
                        child: ClipPath(
                          clipper: InvertedCircleClipper(),
                          child: Container(
                            color: Themes.gradientDeepClr,
                            child: SizedBox(
                              height: 150,
                              width: 150,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          child: TextFormField(
                                            keyboardType: TextInputType.number,
                                            style: const TextStyle(
                                                fontSize: 40,
                                                color: Colors.white),
                                            controller: _discountController,
                                            decoration: const InputDecoration(
                                              hintText: 'Discount',
                                              hintStyle: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 20),
                                            ),
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return 'Please enter discount';
                                              }
                                              return null;
                                            },
                                          ),
                                        ),
                                        const Text(
                                          '%',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 50),
                                        ),
                                      ],
                                    ),
                                    const Text(
                                      'SALE OFF',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 20),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      ClipPath(
                        clipper: InvertedCircleClipper(),
                        child: Container(
                          color: Themes.gradientLightClr,
                          child: SizedBox(
                            height: 150,
                            width: 200,
                            child: Center(
                              child: TextFormField(
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontSize: 30, color: Colors.white),
                                controller: _voucherCodeController,
                                decoration: const InputDecoration(
                                    hintStyle: TextStyle(
                                        color: Colors.white, fontSize: 25),
                                    hintText: 'Voucher Code'),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter voucher code';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
            ),
            child: ElevatedButton(
              onPressed: () {
                createVoucher();
              },
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 0, vertical: 12.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                minimumSize: const Size(double.infinity, 0),
                backgroundColor: Themes.gradientDeepClr, // Đặt màu nền của nút
                foregroundColor: Colors.white, // Đặt màu chữ của nút
                // primary: Themes.gradientLightClr,
                // onPrimary: Colors.white,
              ),
              child: const Text(
                'Tạo mới',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const ListVoucherScreen(),
        ],
      ),
    );
  }
}

class ListVoucherScreen extends StatefulWidget {
  const ListVoucherScreen({Key? key}) : super(key: key);

  @override
  _ListVoucherScreenState createState() => _ListVoucherScreenState();
}

class _ListVoucherScreenState extends State<ListVoucherScreen> {
  final Stream<QuerySnapshot> _vouchersStream =
      FirebaseFirestore.instance.collection('vouchers').snapshots();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('vouchers').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return const Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("Loading");
        }

        if (snapshot.data == null) {
          return const Text("No data available");
        }

        return Expanded(
          child: Container(
            color: Colors.grey[300],
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                DocumentSnapshot voucher = snapshot.data!.docs[index];
                return GestureDetector(
                  onDoubleTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Xác nhận xóa'),
                          content: const Text('Bạn muốn xóa mã giảm giá này?'),
                          actions: <Widget>[
                            TextButton(
                              child: const Text('Hủy'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            TextButton(
                              child: const Text('Xác nhận'),
                              onPressed: () {
                                // Gọi hàm để xóa voucher khỏi cơ sở dữ liệu
                                deleteVoucher(voucher.id);
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Container(
                            decoration: BoxDecoration(
                                border: Border.all(
                                  color:
                                      Colors.black, // Đặt màu viền là màu đen
                                  width: 1, // Đặt độ rộng của viền
                                ),
                                color: Colors.white,
                                borderRadius: const BorderRadius.only(
                                    topRight: Radius.circular(15),
                                    bottomRight: Radius.circular(15))),
                            child: Row(
                              children: [
                                Container(
                                  width: 10,
                                  height: 80,
                                  decoration: const BoxDecoration(
                                    color: Colors.blue,
                                  ),
                                ),
                                Container(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  child: Row(
                                    children: [
                                      Image.asset(
                                        'assets/coupon.png', // Đường dẫn đến hình ảnh của bạn
                                        width: 60, // Chiều rộng của hình ảnh
                                        height: 60, // Chiều cao của hình ảnh
                                        fit: BoxFit
                                            .cover, // Phương pháp fill của hình ảnh
                                      ),
                                      const SizedBox(width: 8),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            voucher['voucherCode'],
                                            style: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.red),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Discount: ${voucher['discount']}%',
                                            style: const TextStyle(
                                                fontSize: 14,
                                                color: Color.fromARGB(
                                                    255, 244, 133, 54)),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.black, // Đặt màu viền là màu đen
                                width: 1, // Đặt độ rộng của viền
                              ),
                              color: Colors.white,
                              borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(15),
                                  bottomLeft: Radius.circular(15)),
                            ),
                            height: 80,
                            child: Center(
                              child: Text(
                                '${voucher['discount']}%',
                                style: const TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                    color: Themes.gradientDeepClr),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

void deleteVoucher(String id) async {
  try {
    await FirebaseFirestore.instance.collection('vouchers').doc(id).delete();
  } catch (e) {
    print(e.toString());
  }
}
